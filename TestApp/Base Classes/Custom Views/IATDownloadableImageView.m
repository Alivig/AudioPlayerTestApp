//
//  IATDownloadableImageView.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATDownloadableImageView.h"
#import "IATDownloader.h"
#import "IATLoader.h"

@interface IATDownloadableImageView ()

@property (nonatomic) IATLoader *loader;
@property (nonatomic) IATDownloadTask *downloadTask;

@property (nonatomic) NSString *storedURLString;  //  to store current URL to image

@end

@implementation IATDownloadableImageView

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    if (self.loader && self.loader.isAnimating) {
        [self.loader stopAnimating];
        self.loader.hidden = YES;
    }
}

- (void)setDownloadableImage:(NSString *)urlString {
    [self setDownloadableImage:urlString withCallback:nil];
}

- (void)setDownloadableImage:(NSString*)urlString withCallback:(IATSuccessCallbackType)callback {
    if (urlString == nil) {
        return;
    }
    
    if (self.storedURLString && [self.storedURLString isEqualToString:urlString]) {
        //  process already initialized
        //  no need to update anything right now
        return;
    }
    
    self.storedURLString = urlString;
    
    //  check if we already have task in progress
    if (self.downloadTask != nil) {
        [[IATDownloader shared] cancelDownloadTask:self.downloadTask];
        self.downloadTask = nil;
    }
    
    self.image = nil;
    
    if (!self.loader) {
        self.loader = [IATLoader showInCenterOfView:self];
    } else {
        [self.loader startAnimating];
    }
    
    __weak IATDownloadableImageView *weakself = self;
    self.downloadTask = [IATDownloadTask taskWithURL:[NSURL URLWithString:urlString] successCallback:^(NSData *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //  we got wrong callback if we have different urlStrings
            if ([weakself.storedURLString isEqualToString:urlString]) {
                if (data != nil) {
                    UIImage *img = [UIImage imageWithData:data];
                    if (img != nil) {
                        weakself.image = img;
                        [weakself setNeedsDisplay];
                    }
                }
                if (callback != nil) {
                    callback(YES);
                }
                //  release downloadTask
                weakself.downloadTask = nil;
            }
        });
    } errorCallback:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //  we got wrong callback if we have different urlStrings
            if ([weakself.storedURLString isEqualToString:urlString]) {
                if (weakself.loader != nil && weakself.loader.isAnimating) {
                    [weakself.loader stopAnimating];
                    weakself.loader.hidden = YES;
                }
                if (callback != nil) {
                    callback(NO);
                }
                //  release downloadTask
                weakself.downloadTask = nil;
            }
        });
    } progressCallback:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //  we got wrong callback if we have different urlStrings
            if ([weakself.storedURLString isEqualToString:urlString]) {
                if (weakself.loader != nil && weakself.loader.isAnimating) {
                    weakself.loader.progress = progress;
                }
            }
        });
    }];
    [[IATDownloader shared] startDownloadTask:self.downloadTask];
}

@end
