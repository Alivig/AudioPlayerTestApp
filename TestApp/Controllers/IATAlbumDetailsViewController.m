//
//  IATAlbumDetailsViewController.m
//  TestApp
//
//  Created by Ivan Alekseev on 5/1/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATAlbumDetailsViewController.h"
#import "IATTrackTableViewCell.h"
#import "IATDataFetcher.h"
#import "IATAlbum.h"
#import "IATArtist.h"
#import "IATTrack.h"
#import "IATDownloadableImageView.h"
#import "IATArtistsView.h"
#import "IATPlayerView.h"
#import "IATPlayer.h"
#import "IATLoader.h"
#import "IATFormatter.h"

@interface IATAlbumDetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) IATAlbum *album;

@property (nonatomic, weak) IBOutlet IATDownloadableImageView *albumIcon;
@property (nonatomic, weak) IBOutlet UILabel *albumName;
@property (nonatomic, weak) IBOutlet UILabel *albumYear;
@property (nonatomic, weak) IBOutlet UILabel *albumDuration;
@property (nonatomic, weak) IBOutlet IATArtistsView *artistsView;

@property (nonatomic, weak) IBOutlet UITableView *tracksTable;

@property (nonatomic, weak) IBOutlet IATPlayerView *playerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *playerOffsetConstraint;

@property (nonatomic, weak) IBOutlet IATLoader *dataLoader;

@end

@implementation IATAlbumDetailsViewController

- (instancetype)initWithAlbum:(IATAlbum*)album {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Controllers" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"IATAlbumDetailsViewController"];
    ((IATAlbumDetailsViewController*)vc).album = album;
    return (IATAlbumDetailsViewController*)vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  update self UI
    [self.albumIcon setDownloadableImage:self.album.coverURL];
    self.albumName.text = self.album.name;
    if ([self.album.year integerValue] > 0) {
        self.albumYear.text = [NSString stringWithFormat:@"%@ ", self.album.year];
    } else {
        self.albumYear.text = @"";
    }
    self.albumDuration.text = [NSString stringWithFormat:@"(%@)", [IATFormatter timeStringFromSeconds:self.album.duration]];
    [self.artistsView updateWithArtists:self.album.artists];
    
    if (self.album.tracks.count > 0) {
        [self.dataLoader stopAnimating];
        self.dataLoader.hidden = YES;
        [self.playerView setTracks:self.album.tracks];
    } else {
        [self.dataLoader startAnimating];
    }
    
    //  hide player controls until user selected any
    CGFloat safeAreaOffset = 0.f;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        safeAreaOffset = window.safeAreaInsets.bottom;
    }
    self.playerOffsetConstraint.constant = -self.playerView.height-safeAreaOffset;
    
    //  update contents
    __weak IATAlbumDetailsViewController *weakself = self;
    [[IATDataFetcher shared] updateDataForAlbum:self.album withCallback:^(BOOL success) {
        [weakself.tracksTable reloadData];
        [weakself.playerView setTracks:weakself.album.tracks];
        [weakself.dataLoader stopAnimating];
        weakself.dataLoader.hidden = YES;
    }];
}

- (void)showPlayer {
    if (self.playerOffsetConstraint.constant != 0) {
        self.playerOffsetConstraint.constant = 0;
        [self.view setNeedsLayout];
        [UIView animateWithDuration:0.15f animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.album.tracks.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IATTrackTableViewCell *cell = (IATTrackTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell updateWithTrack:self.album.tracks[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self.playerView playTrackAtIndex:indexPath.row];
    //  show player controls
    [self showPlayer];
}

@end
