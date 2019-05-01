//
//  IATFormatter.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/30/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATFormatter.h"

@implementation IATFormatter

+ (NSString*)timeStringFromSeconds:(NSInteger)seconds {
    NSMutableString *timeString = [NSMutableString string];
    NSInteger minutes = seconds/60;
    NSInteger hours = minutes/60;
    minutes = minutes%60;
    seconds = seconds%60;
    if (hours > 0) {
        [timeString appendFormat:@"%li:", hours];
    }
    [timeString appendFormat:@"%@%li:", (minutes<10 && hours>0) ? @"0" : @"", minutes];
    [timeString appendFormat:@"%@%li", seconds<10 ? @"0" : @"", seconds];
    
    //  return non-mutable copy
    return [NSString stringWithString:timeString];
}

+ (NSString*)priceStringFromServerPrice:(NSString*)price {
    if (price == nil || [price isEqualToString:@""] || [price floatValue]==0) {
        return @"Free";
    }
    //  TODO: add better support based on available price values
    return price;
}

@end
