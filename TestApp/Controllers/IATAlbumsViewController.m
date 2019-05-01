//
//  IATAlbumsViewController.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATAlbumsViewController.h"
#import "IATDatabase.h"
#import "IATDataFetcher.h"
#import "IATAlbum.h"
#import "IATArtist.h"
#import "IATLoader.h"
#import "IATAlbumTableViewCell.h"
#import "IATAlbumDetailsViewController.h"

@interface IATAlbumsViewController () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSFetchedResultsController *albumsFetchedResultsController;

@property (nonatomic, weak) IBOutlet UITableView *albumsTable;
@property (nonatomic, weak) IBOutlet IATLoader *mainLoader;
@property (nonatomic, strong) UIView *bottomLoader;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL initialLoadingFinished;    //  used to block unwanted data calls

@end

@implementation IATAlbumsViewController

- (instancetype)initController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Controllers" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"IATAlbumsViewController"];
    return (IATAlbumsViewController*)vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger albumsCount = [[IATDatabase shared] countObjects:[IATAlbum class] predicate:[NSPredicate predicateWithValue:YES]];
    if (albumsCount > 0) {
        //  there are some albums already loaded, don't show main loder
        [self.mainLoader stopAnimating];
        self.mainLoader.hidden = YES;
    } else {
        [self.mainLoader startAnimating];
    }
    
    [self.albumsTable addSubview:self.refreshControl];
    
    __weak IATAlbumsViewController *weakself = self;
    [[IATDataFetcher shared] reloadAlbumsWithCallback:^(BOOL success) {
        [weakself.mainLoader stopAnimating];
        weakself.mainLoader.hidden = YES;
        weakself.initialLoadingFinished = YES;
    }];
}

#pragma mark - Refresh

- (UIRefreshControl *)refreshControl {
    if (_refreshControl == nil) {
        _refreshControl = [[UIRefreshControl alloc] init];
        _refreshControl.backgroundColor = self.albumsTable.backgroundColor;
        [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (void)refresh {
    __weak IATAlbumsViewController *weakself = self;
    [[IATDataFetcher shared] reloadAlbumsWithCallback:^(BOOL success) {
        [weakself.refreshControl endRefreshing];
    }];
}

#pragma mark - Bottom Loading indicator

- (UIView*)bottomLoader {
    if (!_bottomLoader) {
        _bottomLoader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 60.0f)];
        [IATLoader showInCenterOfView:_bottomLoader];
    }
    
    IATLoader *loader = (IATLoader*)_bottomLoader.subviews[0];
    [loader startAnimating];
    
    return _bottomLoader;
}

#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionInfo = [[self.albumsFetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(IATAlbumTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    IATAlbum *albumInfo = [self.albumsFetchedResultsController objectAtIndexPath:indexPath];
    [cell updateWithAlbum:albumInfo];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IATAlbumTableViewCell *cell = (IATAlbumTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //  load more data when user scrolls to last row
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section]-1) {
        if (!self.initialLoadingFinished) {
            //  initial loading not done
            return;
        }
        
        self.albumsTable.tableFooterView = [self bottomLoader];
        
        //  load more
        __weak IATAlbumsViewController *weakself = self;
        [[IATDataFetcher shared] loadMoreAlbumsWithCallback:^(BOOL success) {
            weakself.albumsTable.tableFooterView = nil;
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //  go to album details screen
    IATAlbum *albumInfo = [self.albumsFetchedResultsController objectAtIndexPath:indexPath];
    IATAlbumDetailsViewController *detailsController = [[IATAlbumDetailsViewController alloc] initWithAlbum:albumInfo];
    [self.navigationController pushViewController:detailsController animated:YES];
}

#pragma mark - Fetched Results Controller

- (NSFetchedResultsController*)albumsFetchedResultsController {
    if (_albumsFetchedResultsController != nil) {
        return _albumsFetchedResultsController;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"IATAlbum" inManagedObjectContext:[IATDatabase shared].managedObjectContext];
    [request setEntity:entity];
    //  TODO: set predicate if needed
    [request setPredicate:nil];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]]];
    [request setFetchBatchSize:10];
    [request setReturnsObjectsAsFaults:NO];
    
    _albumsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[IATDatabase shared].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _albumsFetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_albumsFetchedResultsController performFetch:&error]) {
        // TODO: Update to handle the error appropriately.
        IATLog(@"Unresolved fetch error %@, %@", error, [error userInfo]);
    }
    
    return _albumsFetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.albumsTable beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.albumsTable endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.albumsTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.albumsTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.albumsTable cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.albumsTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.albumsTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

@end
