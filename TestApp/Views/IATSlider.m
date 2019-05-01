//
//  IATSlider.m
//  TestApp
//
//  Created by Ivan Alekseev on 5/1/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATSlider.h"

@interface IATSlider () {
    CALayer *backgroundLayer;
    CALayer *activeLayer;
    CALayer *thumbLayer;
    
    CGPoint previousTouchPoint;
    BOOL isAnimating;
}

@end

@implementation IATSlider

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    if (!backgroundLayer) {
        backgroundLayer = [[CALayer alloc] init];
        backgroundLayer.frame = CGRectMake(0.f, self.height-self.barWidth/2.f, self.width, self.barWidth);
        backgroundLayer.backgroundColor = self.backgroundColor.CGColor;
        backgroundLayer.cornerRadius = self.barWidth/2.f;
        backgroundLayer.masksToBounds = YES;
        [self.layer addSublayer:backgroundLayer];
        
        activeLayer = [[CALayer alloc] init];
        activeLayer.frame = CGRectMake(0.f, 0.f, [self currentPosition], self.barWidth);
        activeLayer.backgroundColor = self.activeColor.CGColor;
        [backgroundLayer addSublayer:activeLayer];
    }
    
    if (!thumbLayer) {
        thumbLayer = [[CALayer alloc] init];
        thumbLayer.frame = CGRectMake([self currentPosition]-self.thumbSize, (self.height-self.thumbSize)/2.f, self.thumbSize, self.thumbSize);
        thumbLayer.backgroundColor = self.activeColor.CGColor;
        thumbLayer.cornerRadius = self.thumbSize/2.f;
        [self.layer addSublayer:thumbLayer];
    }
}

- (BOOL)isDraging {
    return isAnimating;
}

- (CGFloat)currentPosition {
    return self.width*[self currentValueFromTotal];
}

- (CGFloat)currentValueFromTotal {
    if (self.maxValue <= self.minValue || self.currentValue <= self.minValue) {
        return 0.f;
    }
    if (self.currentValue > self.maxValue) {
        return 1.f;
    }
    return (self.currentValue-self.minValue)/(self.maxValue-self.minValue);
}

- (void)setMinValue:(CGFloat)minValue {
    _minValue = minValue;
    [self layoutContents];
}

- (void)setCurrentValue:(CGFloat)currentValue {
    _currentValue = currentValue;
    [self layoutContents];
}

- (void)setMaxValue:(CGFloat)maxValue {
    _maxValue = maxValue;
    [self layoutContents];
}

- (void)layoutContents {
    backgroundLayer.frame = CGRectMake(0.f, (self.height-self.barWidth)/2.f, self.width, self.barWidth);
    backgroundLayer.cornerRadius = self.barWidth/2.f;
    activeLayer.frame = CGRectMake(0.f, 0.f, [self currentPosition], self.barWidth);
    if (!isAnimating) {
        thumbLayer.frame = CGRectMake([self currentPosition]-self.thumbSize/2.f, (self.height-self.thumbSize)/2.f, self.thumbSize, self.thumbSize);
        thumbLayer.cornerRadius = self.thumbSize/2.f;
    }
}

- (void)setActiveColor:(UIColor *)activeColor {
    _activeColor = activeColor;
    activeLayer.backgroundColor = activeColor.CGColor;
    thumbLayer.backgroundColor = activeColor.CGColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    backgroundLayer.backgroundColor = backgroundColor.CGColor;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    previousTouchPoint = [touch locationInView:self];
    
    CGRect activeFrame = CGRectMake(thumbLayer.position.x-22.f, thumbLayer.position.y-22.f, 44.f, 44.f);
    if (CGRectContainsPoint(activeFrame, previousTouchPoint)) {
        thumbLayer.transform = CATransform3DMakeScale(1.5f, 1.5f, 1.f);
        isAnimating = YES;
    } else {
        thumbLayer.transform = CATransform3DIdentity;
        isAnimating = NO;
    }
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (isAnimating) {
        CGPoint newPoint = [touch locationInView:self];
        CGFloat dX = newPoint.x-previousTouchPoint.x;
        previousTouchPoint = newPoint;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES] ;
        
        thumbLayer.transform = CATransform3DIdentity;
        CGFloat newXPosition = MIN(MAX(thumbLayer.position.x+dX, 0.f), self.width);
        thumbLayer.position = CGPointMake(newXPosition, self.height/2.f);
        thumbLayer.transform = CATransform3DMakeScale(1.5f, 1.5f, 1.f);
        
        _currentValue = _minValue+(_maxValue-_minValue)*newXPosition/self.width;
        [self layoutContents];
        
        [CATransaction commit];
        
        [self notifyDelegates];
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    //  checking end time
    [self finalAnimation];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [self finalAnimation];
}

- (void)finalAnimation {
    [UIView animateWithDuration:0.1 animations:^{
        self->thumbLayer.position = CGPointMake(MIN(MAX(self->thumbLayer.position.x, 0.f), self.width), self->thumbLayer.position.y);
        self->thumbLayer.transform = CATransform3DIdentity;
        [self layoutContents];
    } completion:^(BOOL finished) {
        self->isAnimating = NO;
    }];
}

- (void)notifyDelegates {
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
