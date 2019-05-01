//
//  UIColor+IATAdditions.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "UIColor+IATAdditions.h"

@implementation UIColor (IATAdditions)

+ (UIColor *)colorFromHex:(NSString *)hex {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"#%@", hex]];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0f
                           green:((rgbValue & 0xFF00) >> 8) / 255.0f
                            blue:(rgbValue & 0xFF) / 255.0f
                           alpha:1.0f];
}

@end
