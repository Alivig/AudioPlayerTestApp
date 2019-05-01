//
//  IATDownloader.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IATDownloadTask.h"

@interface IATDownloader : NSObject

+ (IATDownloader*)shared;

//  uses default store location
- (IATDownloadTask*)downloadDataFromURL:(NSURL*)url withSuccessCallback:(IATDataCallbackType)successCallback errorCallback:(IATErrorCallbackType)errorCallback;

//  downloads data to specified location
- (IATDownloadTask*)downloadDataFromURL:(NSURL*)url atStore:(IATDownloaderStoreType)storeType withSuccessCallback:(IATDataCallbackType)successCallback errorCallback:(IATErrorCallbackType)errorCallback;

//  downloads data to specified location and specified filename
- (IATDownloadTask*)downloadDataFromURL:(NSURL*)url atStore:(IATDownloaderStoreType)storeType fileName:(NSString*)fileName withSuccessCallback:(IATDataCallbackType)successCallback errorCallback:(IATErrorCallbackType)errorCallback;

//  downloads data with specified IATDownloadTask object, which specifies all other properties
- (void)startDownloadTask:(IATDownloadTask*)task;
- (void)cancelDownloadTask:(IATDownloadTask*)task;

@end
