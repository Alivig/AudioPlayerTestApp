//
//  IATFormatter.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/30/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IATFormatter : NSObject

+ (NSString*)timeStringFromSeconds:(NSInteger)seconds;
+ (NSString*)priceStringFromServerPrice:(NSString*)price;

@end
