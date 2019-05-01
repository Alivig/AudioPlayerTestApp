//
//  IATDataFetcher.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATDataFetcher.h"
#import "IATDataManager.h"
#import "IATAPICall.h"
#import "IATDatabase.h"
#import "IATAlbum.h"
#import "IATArtist.h"
#import "IATTrack.h"
#import "Reachability.h"

static NSInteger resultsLimit = 10;

static NSString *reachabilityURLString = @"api.mobimusic.kz";
static NSString *albumsAPIEndPoint = @"https://api.mobimusic.kz/?method=product.getNews";
static NSString *albumDetailsAPIEndPoint = @"https://api.mobimusic.kz/?method=product.getCard";

@interface IATDataFetcher () {
    Reachability *reachability;
    BOOL networkReachable;
}

@end

@implementation IATDataFetcher

+ (IATDataFetcher*)shared {
    static IATDataFetcher *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[IATDataFetcher alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReachability:) name:kReachabilityChangedNotification object:nil];
        reachability = [Reachability reachabilityWithHostName:reachabilityURLString];
        [reachability startNotifier];
        [self updateReachability:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)updateReachability:(NSNotification *)note {
    networkReachable = [reachability currentReachabilityStatus]!=NotReachable;
}

- (void)reloadAlbumsWithCallback:(IATSuccessCallbackType)callback {
    //  check if we have connection before doing anything
    if (!networkReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback != nil) {
                callback(NO);
            }
        });
        return;
    }
    
    //  clear out currently saved albums
    [[IATDatabase shared] resetAlbums];
    
    //  load more albums with offset 0
    [self loadAlbumsFromOfffset:0 withCallback:^(BOOL success) {
        if (success) {
            //  fire callback on main thread
            //  data should be loaded already
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback != nil) {
                    callback(YES);
                }
            });
        } else {
            //  fire callback on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback != nil) {
                    callback(NO);
                }
            });
        }
    }];
}

- (void)loadMoreAlbumsWithCallback:(IATSuccessCallbackType)callback {
    //  check if we have connection before doing anything
    if (!networkReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback != nil) {
                callback(NO);
            }
        });
    }
    
    NSInteger currentAlbumsCount = [[IATDatabase shared] countObjects:[IATAlbum class] predicate:[NSPredicate predicateWithValue:YES]];
    //  load more albums with albums count offset
    [self loadAlbumsFromOfffset:currentAlbumsCount withCallback:^(BOOL success) {
        if (success) {
            //  fire callback on main thread
            //  data should be loaded already
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback != nil) {
                    callback(YES);
                }
            });
        } else {
            //  fire callback on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback != nil) {
                    callback(NO);
                }
            });
        }
    }];
}

//  this method fires callbacks in background thread and shouldn't be used outside of this class
- (void)loadAlbumsFromOfffset:(NSInteger)offset withCallback:(IATSuccessCallbackType)callback {
    __weak IATDataFetcher *weakself = self;
    
    NSString *urlString = [albumsAPIEndPoint stringByAppendingFormat:@"&limit=%li&page=%li", resultsLimit, offset/resultsLimit+1];
    [[IATAPICall shared] APICallWithURL:urlString withSuccessCallback:^(NSObject *object) {
        //  check if we got errror
        if ([weakself responseContainsError:(NSDictionary*)object]) {
            //  fire callback with failure
            if (callback != nil) {
                callback(NO);
            }
        }
        
        //  parse collections
        NSDictionary *collectionDictionary = ((NSDictionary*)object)[@"collection"];
        [weakself parseCollections:collectionDictionary];
        
        //  update albums data
        NSDictionary *responseDictionary = ((NSDictionary*)object)[@"response"];
        if (responseDictionary != nil) {
            if (responseDictionary[@"albums"] != nil && [responseDictionary[@"albums"] isKindOfClass:[NSArray class]]) {
                NSArray *albumsIDs = responseDictionary[@"albums"];
                for (int i=0; i<albumsIDs.count; i++) {
                    NSString *albumID = [albumsIDs[i] description];
                    IATAlbum *album = [IATAlbum albumFromAlbumID:albumID];
                    if (album != nil) {
                        album.sortOrder = offset+i;
                    }
                }
            }
        }
        
        //  save parsed data
        [[IATDatabase shared] save];
        
        //  fire callback with success
        if (callback != nil) {
            callback(YES);
        }
    } errorCallback:^(NSError *error) {
        //  fire callback with failure
        if (callback != nil) {
            callback(NO);
        }
    }];
}

- (void)updateDataForAlbum:(IATAlbum*)album withCallback:(IATSuccessCallbackType)callback {
    //  check if we have connection before doing anything
    if (!networkReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback != nil) {
                callback(NO);
            }
        });
    }
    
    __weak IATDataFetcher *weakself = self;
    
    NSString *urlString = [albumDetailsAPIEndPoint stringByAppendingFormat:@"&productId=%@", album.albumID];
    [[IATAPICall shared] APICallWithURL:urlString withSuccessCallback:^(NSObject *object) {
        //  check if we got errror
        if ([weakself responseContainsError:(NSDictionary*)object]) {
            //  fire callback with failure
            if (callback != nil) {
                callback(NO);
            }
        }
        
        //  parse collections
        NSDictionary *collectionDictionary = ((NSDictionary*)object)[@"collection"];
        [weakself parseCollections:collectionDictionary];
        
        //  update tracks for current collection
        NSDictionary *responseDictionary = ((NSDictionary*)object)[@"response"];
        if (responseDictionary != nil) {
            NSString *albumID = [responseDictionary nonEmptyStringOrNilFromKey:@"productId"];
            if (albumID != nil) {
                IATAlbum *albumObject = [IATAlbum albumFromAlbumID:albumID];
                if (albumObject != nil) {
                    //  remove all saved tracks objects
                    [albumObject removeTracks:albumObject.tracks];
                    //  populate with new tracks
                    if (responseDictionary[@"productChildIds"] != nil && [responseDictionary[@"productChildIds"] isKindOfClass:[NSArray class]]) {
                        NSArray *childsIDs = responseDictionary[@"productChildIds"];
                        for (int i=0; i<childsIDs.count; i++) {
                            NSString *trackID = [childsIDs[i] description];
                            IATTrack *track = [IATTrack trackFromTrackID:trackID];
                            if (track != nil) {
                                [albumObject addTracksObject:track];
                            }
                        }
                    }
                }
            }
        }
        
        //  save parsed data
        [[IATDatabase shared] save];
        
        //  fire callback on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback != nil) {
                callback(YES);
            }
        });
    } errorCallback:^(NSError *error) {
        //  fire callback on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback != nil) {
                callback(NO);
            }
        });
    }];
}

#pragma mark - Parsing section

- (BOOL)responseContainsError:(NSDictionary*)response {
    if (response == nil || ![response isKindOfClass:[NSDictionary class]]) {
        //  invalid data
        //  TODO: decide what to do there
        return NO;
    } else if (response[@"error"] != nil && [response[@"error"] isKindOfClass:[NSDictionary class]] && [response[@"error"][@"code"] integerValue]!=0) {
        //  contains error
        //  TODO: properly handle error
        return NO;
    }
    return NO;
}

- (void)parseCollections:(NSDictionary*)collection {
    if (collection == nil || ![collection isKindOfClass:[NSDictionary class]]) {
        IATLog(@"Can't parse collection: %@", [collection description]);
        return;
    }
    
    //  TODO: optimize parsing, especially adding artists
    
    //  parse "people" and create/update IATArtist objects
    if (collection[@"people"] != nil && [collection[@"people"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *peopleDict = collection[@"people"];
        for (NSString *artistID in peopleDict) {
            NSDictionary *artistDictionary = peopleDict[artistID];
            if (artistDictionary != nil && [artistDictionary isKindOfClass:[NSDictionary class]]) {
                [[IATDatabase shared] createOrUpdateArtistWithDictionary:artistDictionary];
            }
            
        }
    }
    
    //  parse "track" and create/update IATTrack objects
    if (collection[@"track"] != nil && [collection[@"track"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *tracksDict = collection[@"track"];
        for (NSString *trackID in tracksDict) {
            NSDictionary *trackDictionary = tracksDict[trackID];
            if (trackDictionary != nil && [trackDictionary isKindOfClass:[NSDictionary class]]) {
                IATTrack *track = [[IATDatabase shared] createOrUpdateTrackWithDictionary:trackDictionary];
                
                //  during this update we didn't update "artists" set, let's do this now
                //  clear current version first
                [track removeArtists:track.artists];
                if (trackDictionary[@"peopleIds"] != nil && [trackDictionary[@"peopleIds"] isKindOfClass:[NSArray class]]) {
                    NSArray *artistsIDArray = trackDictionary[@"peopleIds"];
                    for (int i=0; i<artistsIDArray.count; i++) {
                        NSString *artistID = [artistsIDArray[i] description];
                        IATArtist *artist = [IATArtist artistFromArtistID:artistID];
                        if (artist != nil) {
                            [track addArtistsObject:artist];
                        }
                    }
                }
            }
            
        }
    }
    
    //  parse "album" and create/update IATAlbum objects
    if (collection[@"album"] != nil && [collection[@"album"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *albumDict = collection[@"album"];
        for (NSString *albumID in albumDict) {
            NSDictionary *albumDictionary = albumDict[albumID];
            if (albumDictionary != nil && [albumDictionary isKindOfClass:[NSDictionary class]]) {
                IATAlbum *album = [[IATDatabase shared] createOrUpdateAlbumWithDictionary:albumDictionary];
                
                //  during this update we didn't update "artists" set, let's do this now
                //  clear current version first
                [album removeArtists:album.artists];
                if (albumDictionary[@"peopleIds"] != nil && [albumDictionary[@"peopleIds"] isKindOfClass:[NSArray class]]) {
                    NSArray *artistsIDArray = albumDictionary[@"peopleIds"];
                    for (int i=0; i<artistsIDArray.count; i++) {
                        NSString *artistID = [artistsIDArray[i] description];
                        IATArtist *artist = [IATArtist artistFromArtistID:artistID];
                        if (artist != nil) {
                            [album addArtistsObject:artist];
                        }
                    }
                }
            }
            
        }
    }
}

@end
