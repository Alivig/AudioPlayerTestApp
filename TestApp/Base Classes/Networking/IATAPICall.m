//
//  IATAPICall.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATAPICall.h"

@interface IATAPICall () <NSURLSessionDelegate> {
    NSURLSession *session;
}

@end

@implementation IATAPICall

+ (IATAPICall*)shared {
    static IATAPICall *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[IATAPICall alloc] init];
    });
    
    return shared;
}

+ (NSURLSessionConfiguration*)defaultConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    configuration.timeoutIntervalForRequest = 60.f;
    configuration.allowsCellularAccess = YES;
    configuration.HTTPMaximumConnectionsPerHost = 5;
    
    return configuration;
}

- (instancetype)init {
    if (self = [super init]) {
        session = [NSURLSession sessionWithConfiguration:[IATAPICall defaultConfiguration] delegate:self delegateQueue:nil];
    }
    return self;
}

- (NSURLSessionDataTask*)APICallWithURL:(NSString*)url withSuccessCallback:(IATObjectCallbackType)successCallback errorCallback:(IATErrorCallbackType)errorCallback; {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:@"TestApp" forHTTPHeaderField:@"User-Agent"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            if (error.code != NSURLErrorCancelled) {
                IATLog(@"API Call Error: %@", [error description]);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (errorCallback) {
                    errorCallback(error);
                }
            });
        } else {
            NSObject *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successCallback) {
                    successCallback(result);
                }
            });
        }
    }];
    
    if (dataTask != nil) {
        [dataTask resume];
    }
    
    return dataTask;
}

#pragma mark - Session Delegates

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

@end
