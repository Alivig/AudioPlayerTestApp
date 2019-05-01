//
//  IATDatabase.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATDatabase.h"
#import "IATAlbum.h"
#import "IATArtist.h"
#import "IATTrack.h"

static NSString *modelName = @"EnazaTestApp";

@interface IATDatabase () {
    NSManagedObjectContext *backgroundContext;
    BOOL backgroundSaveHasBeenScheduled;
    NSOperationQueue *queue;
}

- (NSArray*)findObjects:(Class)class withPredicate:(NSPredicate*)predicate;

@end

@implementation IATDatabase

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (IATDatabase*)shared {
    static IATDatabase *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[IATDatabase alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initPersistentStore];
        queue = [[NSOperationQueue alloc] init];
        backgroundSaveHasBeenScheduled = NO;
    }
    return self;
}

- (void) initPersistentStore {
    NSPersistentStoreCoordinator *psc = self.persistentStoreCoordinator;
    if (psc) {
        backgroundSaveHasBeenScheduled = NO;
        backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [backgroundContext performBlockAndWait:^{
            [self->backgroundContext setPersistentStoreCoordinator:psc];
        }];
    }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector {
    NSString *prefix = @"create";
    NSString *selectorName = NSStringFromSelector(aSelector);
    if ([[selectorName substringWithRange:NSMakeRange(0, [prefix length])] isEqualToString:prefix]) {
        return [super methodSignatureForSelector:@selector(createDataObject:)];
    }
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSString *selectorName = NSStringFromSelector([anInvocation selector]);
    // begins with create
    NSString *prefix = @"create";
    NSString *classPrefix = @"IAT";
    if ([[selectorName substringWithRange:NSMakeRange(0, [prefix length])] isEqualToString:prefix]) {
        NSString *objectName = [classPrefix stringByAppendingString:[selectorName substringFromIndex:[prefix length]]];
        id object = [self createDataObject:objectName];
        [anInvocation setReturnValue:&object];
    }
}

- (NSManagedObject*)createDataObject:(NSString*)objectName1 {
    Class class = NSClassFromString(objectName1);
    if (!class) {
        IATLog(@"Could not find object called: %@", objectName1);
        return nil;
    }
    if (![self managedObjectModel]) {
        IATLog(@"managedObjectModel is nil when trying to create %@",objectName1);
    }
    NSDictionary* dict = [NSDictionary dictionaryWithDictionary:[[self managedObjectModel] entitiesByName]];
    NSEntityDescription *entity = [dict objectForKey:objectName1];
    NSManagedObject *newObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    return newObject;
}

- (NSManagedObject*)createDataObjectFromClass:(Class)class {
    NSString *className = NSStringFromClass(class);
    return [self createDataObject:className];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.parentContext = backgroundContext;
    }
    return _managedObjectContext;
}

- (void)saveBackgroundContext {
    __weak NSManagedObjectContext* myBgContext = backgroundContext;
    // save backgroundcontext
    backgroundSaveHasBeenScheduled = NO;
    [queue addOperationWithBlock:^{
        // save backgroundcontext
        [myBgContext performBlock:^{
            NSError *error = nil;
            if (![myBgContext save:&error]) {
                IATLog(@"Could not save background context: %@",error);
            }
        }];
    }];
}

- (void)save {
    IATMarker;
    NSError *error;
    if ([self.managedObjectContext save:&error]) {
        if (!backgroundSaveHasBeenScheduled) {
            // schedule a bg context save in main runloop
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self saveBackgroundContext];
            }];
            backgroundSaveHasBeenScheduled = YES;
        }
    } else {
        IATLog(@"Could not save context: %@", error);
    }
}

- (void)deleteObject:(NSManagedObject*)obj {
    if (obj) {
        [self.managedObjectContext deleteObject:obj];
    }
}

- (NSManagedObjectModel *)managedObjectModel {
    return [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        NSPersistentStoreCoordinator* psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSString *storePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", modelName]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:storePath]) {
            NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:modelName ofType:@"sqlite"];
            if ([fileManager fileExistsAtPath:defaultsPath]) {
                NSError *error =  nil;
                if (![fileManager copyItemAtPath:defaultsPath toPath:storePath error:&error]) {
                    IATLog(@"Error copying default db: %@", error);
                }
                
            }
        }
        
        NSURL *storeURL = [NSURL fileURLWithPath:storePath];
        NSError *error;
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES
                                  ,NSInferMappingModelAutomaticallyOption:@YES};
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            IATLog(@"Error opening Core Data store: %@", error);
            // could not automatically migrate... lets delete this store and redo
            if (![fileManager removeItemAtURL:storeURL error:&error]) {
                IATLog(@"Could not delete store: %@", error);
                // show alert and tell user to delete the app
                IATLog(@"Unrecoverable error. Something very bad happened. Please press the home button, delete and reinstall the app.");
            }
            psc = [self persistentStoreCoordinator];
            
        }
        _persistentStoreCoordinator = psc;
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Objects methods

- (NSManagedObject*)findObject:(Class)class predicate:(NSString *)predicateString, ... {
    NSPredicate *predicate;
    va_list args;
    va_start(args, predicateString);
    predicate = [NSPredicate predicateWithFormat:predicateString arguments:args];
    va_end(args);
    
    NSArray *result = [self findObjects:class withPredicate:predicate] ;
    NSManagedObject *obj = nil;
    if ([result count] > 0) {
        obj = [result objectAtIndex:0];
    }
    return obj;
}

- (NSArray*)findObjects:(Class)class predicate:(NSString *)predicateString, ... {
    NSPredicate *predicate;
    va_list args;
    va_start(args, predicateString);
    predicate = [NSPredicate predicateWithFormat:predicateString arguments:args];
    va_end(args);
    return [self findObjects:class withPredicate:predicate];
}

- (NSArray*)findObjects:(Class)class withPredicate:(NSPredicate*)pred {
    return [self findObjects:class withPredicate:pred withCallback:nil];
}

- (NSUInteger)countObjects:(Class)class predicate:(NSPredicate*)pred {
    NSString *className = NSStringFromClass(class);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:className];
    fetchRequest.predicate = pred;
    __block NSUInteger count = 0;
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error;
        count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        if (error) {
            IATLog(@"Error counting %@: %@", className, error);
            [NSException raise:NSGenericException format:@"%@", [error description]];
        }
    }];
    return count;
    
}

- (NSArray*)findObjects:(Class)class withPredicate:(NSPredicate*)pred withCallback:(void(^)(NSArray * result))callback {
    NSString *className = NSStringFromClass(class);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:className];
    [fetchRequest setPredicate:pred];
    
    NSArray*(^fetchBlock)(NSManagedObjectContext *ctxt) = ^NSArray*(NSManagedObjectContext *ctxt) {
        NSError *error = nil;
        NSArray *result = [ctxt executeFetchRequest:fetchRequest error:&error];
        if (error != nil) {
            IATLog(@"Error fetching %@: %@", className, error);
            [NSException raise:NSGenericException format:@"%@", [error description]];
        }
        return result;
    };
    
    if (callback) { // execute in background
        fetchRequest.resultType = NSManagedObjectIDResultType;
        [backgroundContext performBlock:^{
            NSArray *results = fetchBlock(self->backgroundContext);
            [self.managedObjectContext performBlock:^{
                NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[results count]];
                for (NSManagedObjectID *oid in results) {
                    [array addObject:[self.managedObjectContext objectWithID:oid]];
                }
                callback(array);
            }];
        }];
        return nil;
    } else {
        __block NSArray *result;
        [self.managedObjectContext performBlockAndWait:^{
            result = fetchBlock(self.managedObjectContext);
        }];
        return result;
    }
    
}

#pragma mark - Albums

- (void)resetAlbums {
    NSArray *allAlbums = [self findObjects:[IATAlbum class] withPredicate:[NSPredicate predicateWithValue:YES]];
    for (IATAlbum *album in allAlbums) {
        [self.managedObjectContext deleteObject:album];
    }
}

#pragma mark - Create or Update

- (IATAlbum*)createOrUpdateAlbumWithDictionary:(NSDictionary*)d {
    NSString *albumID = [d nonEmptyStringOrNilFromKey:@"id"];
    if (albumID == nil) {
        //  not a valid dictionary to create or update
        return nil;
    }
    
    IATAlbum *album = (IATAlbum*)[self findObject:[IATAlbum class] predicate:@"albumID == %@", albumID];;
    if (!album) {
        album = [self createAlbum];
        album.albumID = albumID;
    }
    [album updateWithDictionary:d];
    return album;
}

- (IATArtist*)createOrUpdateArtistWithDictionary:(NSDictionary*)d {
    NSString *artistID = [d nonEmptyStringOrNilFromKey:@"id"];
    if (artistID == nil) {
        //  not a valid dictionary to create or update
        return nil;
    }
    
    IATArtist *artist = (IATArtist*)[self findObject:[IATArtist class] predicate:@"artistID == %@", artistID];;
    if (!artist) {
        artist = [self createArtist];
        artist.artistID = artistID;
    }
    [artist updateWithDictionary:d];
    return artist;
}

- (IATTrack*)createOrUpdateTrackWithDictionary:(NSDictionary*)d {
    NSString *trackID = [d nonEmptyStringOrNilFromKey:@"id"];
    if (trackID == nil) {
        //  not a valid dictionary to create or update
        return nil;
    }
    
    IATTrack *track = (IATTrack*)[self findObject:[IATTrack class] predicate:@"trackID == %@", trackID];;
    if (!track) {
        track = [self createTrack];
        track.trackID = trackID;
    }
    [track updateWithDictionary:d];
    return track;
}

@end
