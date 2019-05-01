//
//  IATDownloadTask.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

//  constants to specify data storage location
//  Cache location (default) should be used for all non-critical data, such as images
//  Documents location should be used for all critical data that should stay through app launches
typedef enum {
    IATDownloaderStoreCache = 0,    //  by default all downloaded data will be store in Cache directory.
    IATDownloaderStoreDocuments,    //  stores items in Documents directory
} IATDownloaderStoreType;

@interface IATDownloadTask : NSObject

//  main URL
@property (nonatomic, copy) NSURL *taskURL;
//  filename for file to save data to
@property (nonatomic, copy) NSString *fileName;
//  specifies where to save downloadable file (Caches or Documents)
@property (nonatomic) IATDownloaderStoreType storeType;
//  called when task finished with success and returns NSData object
@property (nonatomic, copy) IATDataCallbackType successCallback;
//  called when task failed and returns NSError object
@property (nonatomic, copy) IATErrorCallbackType errorCallback;
//  called when task progressed and returns CGFloat in range 0..1
@property (nonatomic, copy) IATProgressCallbackType progressCallback;


//  reference to session download task used for references and ability to cancel tasks
@property (nonatomic, weak) NSURLSessionDownloadTask *downloadTask;

//  in case if we have another task with same url, we will keep reference on it and call callbacks upon progress
@property (nonatomic, weak) IATDownloadTask *duplicatedTask;

+ (IATDownloadTask*)taskWithURL:(NSURL*)url successCallback:(IATDataCallbackType)successCallback errorCallback:(IATErrorCallbackType)errorCallback progressCallback:(IATProgressCallbackType)progressCallback;

//  notifiers
- (void)notifyProgress:(CGFloat)progress;
- (void)notifySuccess:(NSData*)data;
- (void)notifyError:(NSError*)error;

@end
