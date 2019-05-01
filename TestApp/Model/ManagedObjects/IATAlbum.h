//
//  IATAlbum.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATModel.h"

@class IATArtist, IATTrack;

@interface IATAlbum : NSManagedObject <IATModel>

@property (nonnull, nonatomic, copy) NSString *albumID;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *coverURL;
@property (nullable, nonatomic, copy) NSString *year;
@property (nullable, nonatomic, copy) NSString *price;
@property (nullable, nonatomic, copy) NSString *dir;
@property (nullable, nonatomic, copy) NSString *state;
@property (nonatomic) int16_t duration;
@property (nonatomic) BOOL liked;
@property (nonatomic) int16_t sortOrder;

//  relationships
@property (nullable, nonatomic, retain) NSOrderedSet <IATArtist*> *artists;
@property (nullable, nonatomic, retain) NSOrderedSet <IATTrack*> *tracks;

+ (IATAlbum*)albumFromAlbumID:(NSString*)albumID;

@end

@interface IATAlbum (CoreDataGeneratedAccessors)

- (void)insertObject:(IATArtist *)value inArtistsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromArtistsAtIndex:(NSUInteger)idx;
- (void)insertArtists:(NSArray<IATArtist *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeArtistsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInArtistsAtIndex:(NSUInteger)idx withObject:(IATArtist *)value;
- (void)replaceArtistsAtIndexes:(NSIndexSet *)indexes withArtists:(NSArray<IATArtist *> *)values;
- (void)addArtistsObject:(IATArtist *)value;
- (void)removeArtistsObject:(IATArtist *)value;
- (void)addArtists:(NSOrderedSet<IATArtist *> *)values;
- (void)removeArtists:(NSOrderedSet<IATArtist *> *)values;

- (void)insertObject:(IATTrack *)value inTracksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTracksAtIndex:(NSUInteger)idx;
- (void)insertTracks:(NSArray<IATTrack *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTracksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTracksAtIndex:(NSUInteger)idx withObject:(IATTrack *)value;
- (void)replaceTracksAtIndexes:(NSIndexSet *)indexes withTracks:(NSArray<IATTrack *> *)values;
- (void)addTracksObject:(IATTrack *)value;
- (void)removeTracksObject:(IATTrack *)value;
- (void)addTracks:(NSOrderedSet<IATTrack *> *)values;
- (void)removeTracks:(NSOrderedSet<IATTrack *> *)values;

@end
