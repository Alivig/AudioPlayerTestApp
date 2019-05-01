//
//  IATTrack.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATTrack.h"
#import "IATDatabase.h"
#import "IATArtist.h"

static NSString *tracksCoverBaseURL = @"https://static-cdn.enazadev.ru/";

@implementation IATTrack

@dynamic trackID;
@dynamic name;
@dynamic coverURL;
@dynamic year;
@dynamic price;
@dynamic dir;
@dynamic state;
@dynamic duration;
@dynamic liked;
@dynamic hasLyrics;
@dynamic lyrics;
@dynamic artists;
@dynamic album;

+ (IATTrack*)trackFromTrackID:(NSString*)trackID {
    return (IATTrack*)[[IATDatabase shared] findObject:[IATTrack class] predicate:@"trackID == %@", trackID];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    self.trackID = [dictionary nonEmptyStringOrNilFromKey:@"id"];
    self.name = [dictionary nonEmptyStringOrNilFromKey:@"name"];
    NSString *cover = [dictionary nonEmptyStringOrNilFromKey:@"cover"];
    if (cover != nil) {
        self.coverURL = [tracksCoverBaseURL stringByAppendingString:cover];
    }
    self.year = [dictionary nonEmptyStringOrNilFromKey:@"year"];
    self.price = [dictionary nonEmptyStringOrNilFromKey:@"price"];
    self.dir = [dictionary nonEmptyStringOrNilFromKey:@"dir"];
    self.state = [dictionary nonEmptyStringOrNilFromKey:@"state"];
    self.duration = [dictionary[@"duration"] integerValue];
    self.liked = [dictionary[@"isUserLikes"] boolValue];
    self.lyrics = [dictionary nonEmptyStringOrNilFromKey:@"lyrics2"];
    self.hasLyrics = [dictionary[@"hasLyrics"] boolValue];
}

@end
