//
//  IATDownloader.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATDownloader.h"
#import "IATDataManager.h"

@interface IATDownloader () <NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    NSURLSession *session;
    //  downloadTasks will keep all current downloads
    NSMutableDictionary <NSURLSessionDownloadTask *, IATDownloadTask *> *downloadTasks;
}

@end

@implementation IATDownloader

+ (IATDownloader*)shared {
    static IATDownloader *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[IATDownloader alloc] init];
    });
    
    return shared;
}

+ (NSURLSessionConfiguration*)defaultConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    configuration.timeoutIntervalForResource = 60.f;
    configuration.allowsCellularAccess = YES;
    configuration.HTTPMaximumConnectionsPerHost = 5;
    
    return configuration;
}

- (instancetype)init {
    if (self = [super init]) {
        session = [NSURLSession sessionWithConfiguration:[IATDownloader defaultConfiguration] delegate:self delegateQueue:nil];
        downloadTasks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (IATDownloadTask*)downloadDataFromURL:(NSURL*)url withSuccessCallback:(IATDataCallbackType)successCallback errorCallback:(IATErrorCallbackType)errorCallback {
    return [self downloadDataFromURL:url atStore:IATDownloaderStoreCache fileName:nil withSuccessCallback:successCallback errorCallback:errorCallback];
}

- (IATDownloadTask*)downloadDataFromURL:(NSURL*)url atStore:(IATDownloaderStoreType)storeType withSuccessCallback:(IATDataCallbackType)successCallback errorCallback:(IATErrorCallbackType)errorCallback {
    return [self downloadDataFromURL:url atStore:storeType fileName:nil withSuccessCallback:successCallback errorCallback:errorCallback];
}

- (IATDownloadTask*)downloadDataFromURL:(NSURL*)url atStore:(IATDownloaderStoreType)storeType fileName:(NSString*)fileName withSuccessCallback:(IATDataCallbackType)successCallback errorCallback:(IATErrorCallbackType)errorCallback {
    
    IATDownloadTask *downloadTask = [[IATDownloadTask alloc] init];
    downloadTask.taskURL = url;
    downloadTask.fileName = fileName;
    downloadTask.storeType = storeType;
    downloadTask.successCallback = successCallback;
    downloadTask.errorCallback = errorCallback;
    
    [self startDownloadTask:downloadTask];
    
    return downloadTask;
}

- (void)startDownloadTask:(IATDownloadTask*)task {
    //  check that we have all data, before starting new task
    //  we can't start without URL
    if (task.taskURL == nil) {
        //  TODO: generate error
        IATLog(@"Problem starting download task for URL %@", task.taskURL);
        return;
    }
    
    //  check if we already have such task in queue
    IATDownloadTask *storedTask = [self taskForURL:task.taskURL];
    if (storedTask != nil) {
        //  we have task with URL that already scheduled
        //  search last in chain
        while (storedTask.duplicatedTask != nil) {
            storedTask = storedTask.duplicatedTask;
        }
        //  add it to the tail
        storedTask.duplicatedTask = task;
        //  nothing to do there, just return
        return;
    }
    
    //  check if we already have file for this task
    if (task.storeType == IATDownloaderStoreDocuments) {
        NSData *data = [IATDataManager dataForKey:task.fileName];
        if (data != nil) {
            [task notifySuccess:data];
            //  no need to download it again
            return;
        }
    } else if (task.storeType == IATDownloaderStoreCache) {
        NSData *data = [IATDataManager cacheDataForKey:task.fileName];
        if (data != nil) {
            [task notifySuccess:data];
            //  no need to download it again
            return;
        }
    }
    
    
    //  add new download task and start it
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:task.taskURL];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    [downloadTask resume];
    
    //  TODO: add support for resuming download tasks
    
    //  update task's download part
    task.downloadTask = downloadTask;
    //  add it to current tasks dictionary
    downloadTasks[downloadTask] = task;
}

- (void)cancelDownloadTask:(IATDownloadTask*)task {
    IATDownloadTask *storedTask = [self taskForURL:task.taskURL];
    if (storedTask != nil) {
        [storedTask.downloadTask cancel];
        //  TODO: add support for resuming download tasks
    }
}

#pragma mark - Helpers

//  returns IATDownloadTask based on URL. if there is no such requests in queue, returns nil
- (IATDownloadTask*)taskForURL:(NSURL*)url {
    NSArray *keysArray = downloadTasks.allKeys;
    for (int i=0; i<keysArray.count; i++) {
        if ([downloadTasks[keysArray[i]].downloadTask.originalRequest.URL.absoluteString isEqualToString:url.absoluteString]) {
            return downloadTasks[keysArray[i]];
        }
    }
    return nil;
}

#pragma mark - NSURLSession Delegate methods
#pragma mark Base methods

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    //  TODO: implement reset based on error
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    
    NSURLCredential *credentials = [NSURLCredential credentialWithUser:@"username" password:@"password" persistence:NSURLCredentialPersistencePermanent];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credentials);
}

//  We're not going to use it, but will check if it fired
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
}

#pragma mark Download methods

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    //  get related task
    IATDownloadTask *storedTask = [self taskForURL:task.originalRequest.URL];
    if (storedTask != nil) {
        if (error != nil) {
            [storedTask notifyError:error];
        }
        //  successfull execution already notified tasks through URLSession:downlodTask:didFinishDownloadingToURL: method
        //  remove task from current tasks dictionary
        [downloadTasks removeObjectForKey:storedTask.downloadTask];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    //  get downloaded data
    NSData *data = [NSData dataWithContentsOfURL:location];
    if (data != nil) {
        //  save it to needed location
        IATDownloadTask *task = [self taskForURL:downloadTask.originalRequest.URL];
        if (task != nil) {
            if (task.storeType == IATDownloaderStoreDocuments) {
                [IATDataManager saveData:data withKey:task.fileName];
            } else if (task.storeType == IATDownloaderStoreCache) {
                [IATDataManager saveDataToCache:data withKey:task.fileName];
            }
            //  fire success callback
            [task notifySuccess:data];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // check if we have task in dictionary
    IATDownloadTask *task = [self taskForURL:downloadTask.originalRequest.URL];
    if (task != nil) {
        //  check and fire progress callback
        [task notifyProgress:(float)totalBytesWritten/(float)totalBytesExpectedToWrite];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    //  TODO: add support for resuming download tasks
}

@end
