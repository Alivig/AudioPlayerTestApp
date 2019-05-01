//
//  NSArray+IATAdditions.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (IATAdditions)

// returns an array containing the result of running the block using each object in the array as a parameter
-(NSArray*)arrayByApplyingBlock:(id(^)(id))func;

@end
