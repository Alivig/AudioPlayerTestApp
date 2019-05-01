//
//  IATDataFetcher.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/29/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IATAlbum;

@interface IATDataFetcher : NSObject

+ (IATDataFetcher*)shared;

//  next methods will update data and notify through callbacks with success/failure when it's done and ready to update UI
//  clear out all loaded albums info and load new set of data.
- (void)reloadAlbumsWithCallback:(IATSuccessCallbackType)callback;
//  load albums based on already loaded data
- (void)loadMoreAlbumsWithCallback:(IATSuccessCallbackType)callback;
//  update data for some album (load tracks)
- (void)updateDataForAlbum:(IATAlbum*)album withCallback:(IATSuccessCallbackType)callbck;

@end
