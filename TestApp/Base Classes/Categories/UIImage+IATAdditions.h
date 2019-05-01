//
//  UIImage+IATAdditions.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (IATAdditions)

- (UIImage *)imageFilledWithColor:(UIColor *)tintColor;
- (UIImage *)imageWithTint:(UIColor *)tintColor;
- (UIImage *)imageWithAlpha:(CGFloat)alpha;

@end
