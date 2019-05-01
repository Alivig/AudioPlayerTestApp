//
//  IATAlbum.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATAlbum.h"
#import "IATTrack.h"
#import "IATArtist.h"
#import "IATDatabase.h"

static NSString *albumsCoverBaseURL = @"https://static-cdn.enazadev.ru/";

@implementation IATAlbum

@dynamic albumID;
@dynamic name;
@dynamic coverURL;
@dynamic year;
@dynamic price;
@dynamic dir;
@dynamic state;
@dynamic duration;
@dynamic liked;
@dynamic sortOrder;
@dynamic artists;
@dynamic tracks;

+ (IATAlbum*)albumFromAlbumID:(NSString*)albumID {
    return (IATAlbum*)[[IATDatabase shared] findObject:[IATAlbum class] predicate:@"albumID == %@", albumID];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    self.albumID = [dictionary nonEmptyStringOrNilFromKey:@"id"];
    self.name = [dictionary nonEmptyStringOrNilFromKey:@"name"];
    NSString *cover = [dictionary nonEmptyStringOrNilFromKey:@"cover"];
    if (cover != nil) {
        self.coverURL = [albumsCoverBaseURL stringByAppendingString:cover];
    }
    self.year = [dictionary nonEmptyStringOrNilFromKey:@"year"];
    self.price = [dictionary nonEmptyStringOrNilFromKey:@"price"];
    self.dir = [dictionary nonEmptyStringOrNilFromKey:@"dir"];
    self.state = [dictionary nonEmptyStringOrNilFromKey:@"state"];
    self.duration = [dictionary[@"duration"] integerValue];
    self.liked = [dictionary[@"isUserLikes"] boolValue];
}

@end
