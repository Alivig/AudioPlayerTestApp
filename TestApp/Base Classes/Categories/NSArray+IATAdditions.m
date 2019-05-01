//
//  NSArray+IATAdditions.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "NSArray+IATAdditions.h"

@implementation NSArray (IATAdditions)

- (NSArray*)arrayByApplyingBlock:(id (^)(id))func {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self) {
        id result = func(obj);
        if (result) {
            [array addObject:result];
        }
    }
    return [NSArray arrayWithArray:array];
}

@end
