//
//  IATRoundedView.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/26/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATRoundedView.h"

@implementation IATRoundedView

-(void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

@end
