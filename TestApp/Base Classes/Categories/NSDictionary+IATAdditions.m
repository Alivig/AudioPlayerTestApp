//
//  NSDictionary+IATAdditions.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/25/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "NSDictionary+IATAdditions.h"

@implementation NSDictionary (IATAdditions)

- (NSString*)nonEmptyStringOrNilFromKey:(NSString*)key {
    if (self[key] != nil && ![self[key] isKindOfClass:[NSNull class]]) {
        NSString *returnValue = [self[key] description];
        if (![returnValue isEqualToString:@""]) {
            return returnValue;
        }
    }
    return nil;
}

@end
