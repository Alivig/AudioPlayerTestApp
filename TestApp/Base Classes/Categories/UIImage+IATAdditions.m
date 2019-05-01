//
//  UIImage+IATAdditions.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "UIImage+IATAdditions.h"

@implementation UIImage (IATAdditions)

- (UIImage *)imageFilledWithColor:(UIColor *)tintColor {
    // Begin drawing
    CGRect aRect = CGRectMake(0.f, 0.f, self.size.width, self.size.height);
    __block UIImage *newImage;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
        // Get the graphic context
        CGContextRef c = UIGraphicsGetCurrentContext();
        // Converting a UIImage to a CGImage flips the image,
        // so apply a upside-down translation
        CGContextTranslateCTM(c, 0, self.size.height);
        CGContextScaleCTM(c, 1.0f, -1.0f);
        // Set the mask to only tint non-transparent pixels
        CGContextClipToMask(c, aRect, self.CGImage);
        // Set the fill color
        CGContextSetFillColorWithColor(c, tintColor.CGColor);
        CGContextFillRect(c, aRect);
        //CGContextSetBlendMode(c, kCGBlendModeMultiply);
        newImage= [UIGraphicsGetImageFromCurrentImageContext() copy];
        UIGraphicsEndImageContext();
    }
    return newImage;
}

- (UIImage *)imageWithTint:(UIColor *)tintColor {
    // Begin drawing
    CGRect aRect = CGRectMake(0.f, 0.f, self.size.width, self.size.height);
    __block UIImage *newImage;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
        // Get the graphic context
        CGContextRef c = UIGraphicsGetCurrentContext();
        // Converting a UIImage to a CGImage flips the image,
        // so apply a upside-down translation
        CGContextTranslateCTM(c, 0, self.size.height);
        CGContextScaleCTM(c, 1.0f, -1.0f);
        // Set the mask to only tint non-transparent pixels
        CGContextClipToMask(c, aRect, self.CGImage);
        // Set the fill color
        CGContextDrawImage(c, aRect, self.CGImage);
        CGContextSetFillColorWithColor(c, tintColor.CGColor);
        CGContextFillRect(c, aRect);
        newImage= [UIGraphicsGetImageFromCurrentImageContext() copy];
        UIGraphicsEndImageContext();
    }
    return newImage;
}

- (UIImage *)imageWithAlpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
