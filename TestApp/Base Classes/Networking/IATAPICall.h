//
//  IATAPICall.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IATAPICall : NSObject

+ (IATAPICall*)shared;

- (NSURLSessionDataTask*)APICallWithURL:(NSString*)url withSuccessCallback:(IATObjectCallbackType)successCallback errorCallback:(IATErrorCallbackType)errorCallback;

@end
