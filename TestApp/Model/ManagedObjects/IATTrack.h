//
//  IATTrack.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATModel.h"

@class IATArtist, IATAlbum;

@interface IATTrack : NSManagedObject <IATModel>

@property (nonnull, nonatomic, copy) NSString *trackID;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *coverURL;
@property (nullable, nonatomic, copy) NSString *year;
@property (nullable, nonatomic, copy) NSString *price;
@property (nullable, nonatomic, copy) NSString *dir;
@property (nullable, nonatomic, copy) NSString *state;
@property (nonatomic) int16_t duration;
@property (nonatomic) BOOL liked;
@property (nonatomic) BOOL hasLyrics;
@property (nullable, nonatomic, copy) NSString *lyrics;

//  relationships
@property (nullable, nonatomic, retain) NSOrderedSet <IATArtist*> *artists;
@property (nullable, nonatomic, retain) IATAlbum *album;

+ (IATTrack*)trackFromTrackID:(NSString*)trackID;

@end

@interface IATTrack (CoreDataGeneratedAccessors)

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

@end
