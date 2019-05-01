//
//  IATDownloadTask.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATDownloadTask.h"

@implementation IATDownloadTask

+ (IATDownloadTask*)taskWithURL:(NSURL*)url successCallback:(IATDataCallbackType)successCallback errorCallback:(IATErrorCallbackType)errorCallback progressCallback:(IATProgressCallbackType)progressCallback {
    IATDownloadTask *task = [[IATDownloadTask alloc] init];
    task.taskURL = url;
    task.successCallback = successCallback;
    task.errorCallback = errorCallback;
    task.progressCallback = progressCallback;
    return task;
}

//  returns filename based on settings
//  class assumes that url already set
- (NSString*)fileName {
    if (_fileName != nil) {
        return _fileName;
    }
    
    if (_taskURL != nil) {
        return [_taskURL lastPathComponent];
    }
    
    return nil;
}

- (void)setDuplicatedTask:(IATDownloadTask *)duplicatedTask {
    _duplicatedTask = duplicatedTask;
    duplicatedTask.downloadTask = self.downloadTask;
}

- (void)notifyProgress:(CGFloat)progress {
    if (self.progressCallback != nil) {
        self.progressCallback(progress);
    }
    
    if (self.duplicatedTask != nil) {
        [self.duplicatedTask notifyProgress:progress];
    }
}

- (void)notifySuccess:(NSData*)data {
    if (self.successCallback != nil) {
        self.successCallback(data);
    }
    
    if (self.duplicatedTask != nil) {
        [self.duplicatedTask notifySuccess:data];
    }
}

- (void)notifyError:(NSError*)error {
    if (self.errorCallback != nil) {
        self.errorCallback(error);
    }
    
    if (self.duplicatedTask != nil) {
        [self.duplicatedTask notifyError:error];
    }
}

@end
