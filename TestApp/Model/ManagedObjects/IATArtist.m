//
//  IATArtist.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATArtist.h"
#import "IATDatabase.h"

static NSString *artistsCoverBaseURL = @"https://static-cdn.enazadev.ru/";

@implementation IATArtist

@dynamic artistID;
@dynamic name;
@dynamic coverURL;
@dynamic artistDescription;
@dynamic typeName;
@dynamic dir;
@dynamic albumsCount;
@dynamic tracksCount;
@dynamic liked;

+ (IATArtist*)artistFromArtistID:(NSString *)artistID {
    return (IATArtist*)[[IATDatabase shared] findObject:[IATArtist class] predicate:@"artistID == %@", artistID];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    self.artistID = [dictionary nonEmptyStringOrNilFromKey:@"id"];
    self.name = [dictionary nonEmptyStringOrNilFromKey:@"name"];
    NSString *cover = [dictionary nonEmptyStringOrNilFromKey:@"cover_file"];
    if (cover != nil) {
        self.coverURL = [artistsCoverBaseURL stringByAppendingString:cover];
    }
    self.artistDescription = [dictionary nonEmptyStringOrNilFromKey:@"description"];
    self.typeName = [dictionary nonEmptyStringOrNilFromKey:@"typeName"];
    self.dir = [dictionary nonEmptyStringOrNilFromKey:@"dir"];
    self.albumsCount = [dictionary[@"productCount"] integerValue];
    self.tracksCount = [dictionary[@"productChildCount"] integerValue];
    self.liked = [dictionary[@"isUserLikes"] boolValue];
}

@end
