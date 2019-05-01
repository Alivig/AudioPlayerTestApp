//
//  IATArtist.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATModel.h"

@interface IATArtist : NSManagedObject <IATModel>

@property (nonnull, nonatomic, copy) NSString *artistID;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *coverURL;
@property (nullable, nonatomic, copy) NSString *artistDescription;
@property (nullable, nonatomic, copy) NSString *typeName;
@property (nullable, nonatomic, copy) NSString *dir;
@property (nonatomic) int16_t albumsCount;
@property (nonatomic) int16_t tracksCount;
@property (nonatomic) BOOL liked;

+ (IATArtist*)artistFromArtistID:(NSString*)artistID;

@end
