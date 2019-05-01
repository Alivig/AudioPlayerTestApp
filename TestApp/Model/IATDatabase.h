//
//  IATDatabase.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IATAlbum, IATTrack, IATArtist;

@interface IATDatabase : NSObject

+ (IATDatabase*)shared;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSManagedObject*)findObject:(Class)class predicate:(NSString*)predicateString, ... ;
- (NSArray*)findObjects:(Class)class predicate:(NSString*)predicateString, ... ;
- (NSUInteger)countObjects:(Class)class predicate:(NSPredicate*)pred;
- (NSManagedObject*)createDataObjectFromClass:(Class)class;
- (void)deleteObject:(NSManagedObject*)obj;

- (void)save;

- (void)resetAlbums;
- (IATAlbum*)createOrUpdateAlbumWithDictionary:(NSDictionary*)d;
- (IATArtist*)createOrUpdateArtistWithDictionary:(NSDictionary*)d;
- (IATTrack*)createOrUpdateTrackWithDictionary:(NSDictionary*)d;

@end

@interface IATDatabase (DynamicMethods)

- (IATAlbum*)createAlbum;
- (IATTrack*)createTrack;
- (IATArtist*)createArtist;

@end
