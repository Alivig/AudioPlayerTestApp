//
//  IATCustomButton.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATCustomButton.h"
#import "IATLoader.h"

@interface IATCustomButton () {
    IATLoader *loader;
}

@end

@implementation IATCustomButton

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setNormalBorderColor:(UIColor *)normalBorderColor {
    _normalBorderColor = [normalBorderColor copy];
    [self updateBorderState];
}

- (void)setHighlightedBorderColor:(UIColor *)highlightedBorderColor {
    _highlightedBorderColor = [highlightedBorderColor copy];
    [self updateBorderState];
}

- (void)setDisabledBorderColor:(UIColor *)disabledBorderColor {
    _disabledBorderColor = [disabledBorderColor copy];
    [self updateBorderState];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateBorderState];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self updateBorderState];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self updateBorderState];
}

- (void)updateBorderState {
    if (!self.enabled) {
        self.layer.borderColor = self.disabledBorderColor.CGColor;
    } else {
        if (self.selected || self.highlighted) {
            self.layer.borderColor = self.highlightedBorderColor.CGColor;
        } else {
            self.layer.borderColor = self.normalBorderColor.CGColor;
        }
    }
}

- (void)showLoadingIndicator {
    [self showLoadingIndicator:[UIColor blackColor]];
}

- (void)showLoadingIndicatorCentered {
    [self showLoadingIndicatorCentered:[UIColor blackColor]];
}

- (void)showLoadingIndicator:(UIColor *)indicatorColor {
    self.enabled = NO;
    if (!loader) {
        loader = [[IATLoader alloc] initWithFrame:CGRectMake(0.f, 0.f, 20.f, 20.f)];
        loader.center = CGPointMake(self.titleLabel.right + 20.f, self.height/2.f);
        loader.lineWidth = 2.f;
        loader.tintColor = indicatorColor;
        [self addSubview:loader];
    }
    if (!loader.isAnimating) {
        [loader startAnimating];
    }
}

- (void)showLoadingIndicatorCentered:(UIColor *)indicatorColor {
    self.enabled = NO;
    if (!loader) {
        loader = [[IATLoader alloc] initWithFrame:CGRectMake(0.f, 0.f, 20.f, 20.f)];
        loader.center = CGPointMake(self.width/2.f, self.height/2.f);
        loader.lineWidth = 2.f;
        loader.tintColor = indicatorColor;
        [self addSubview:loader];
    }
    if (!loader.isAnimating) {
        [loader startAnimating];
    }
}

- (void)hideLoadingIndicator {
    self.enabled = YES;
    if (loader && [loader isAnimating]) {
        [loader stopAnimating];
    }
}

@end
