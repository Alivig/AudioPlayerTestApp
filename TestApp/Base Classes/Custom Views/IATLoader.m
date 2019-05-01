//
//  IATLoader.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATLoader.h"

#define kKKMLoaderRotationAnimationKey @"kKKMLoaderRotationAnimation"
#define kKKMLoaderEndPointAnimationKey @"kKKMLoaderEndPointAnimation"
#define kKKMLoaderStartPointAnimationKey @"kKKMLoaderStartPointAnimation"

@interface IATLoader () {
    BOOL animating;
    CAShapeLayer *shapeLayer;
}

@end

@implementation IATLoader

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    
    if (!shapeLayer) {
        shapeLayer = [CAShapeLayer new];
        shapeLayer.borderWidth = 0.f;
        shapeLayer.fillColor = UIColor.clearColor.CGColor;
        shapeLayer.lineWidth = 3.f;
        [self.layer addSublayer:shapeLayer];
    }
}

- (BOOL)isAnimating {
    return animating;
}

- (void)dealloc {
    [self unregisterFromNotificationCenter];
}

#pragma mark - Line Width

- (void)setLineWidth:(CGFloat)width {
    shapeLayer.lineWidth = width;
    [self setNeedsDisplay];
}

- (CGFloat)lineWidth {
    return shapeLayer.lineWidth;
}

#pragma mark - Line Color

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    shapeLayer.strokeColor = lineColor.CGColor;
    [self setNeedsDisplay];
}

#pragma mark - Progress

- (void)setProgress:(CGFloat)progress {
    BOOL requiresUpdate = NO;
    if (_progress == 0) {
        requiresUpdate = YES;
    }
    _progress = progress;
    if (requiresUpdate) {
        [self removeAnimation];
        [self addAnimation];
    } else {
        shapeLayer.strokeEnd = MAX(MIN(self.progress, 1.f), 0.f);
    }
    [self setNeedsDisplay];
}

#pragma mark - Notifications

- (void)registerForNotificationCenter {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)unregisterFromNotificationCenter {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center removeObserver:self];
}

- (void)applicationDidEnterBackground:(NSNotification *)note {
    [self removeAnimation];
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    if (self.isAnimating) {
        [self addAnimation];
    }
}

#pragma mark - Global initializer

+ (IATLoader*)showInCenterOfView:(UIView *)v {
    IATLoader *loader = [[IATLoader alloc] initWithFrame:CGRectMake(0.f, 0.f, 20.f, 20.f)];
    loader.lineWidth = 2.f;
    loader.lineColor = [UIColor blackColor];
    loader.center = CGPointMake(v.width/2.f, v.height/2.f);
    [v addSubview:loader];
    [loader startAnimating];
    
    return loader;
}

#pragma mark - Animation

- (void)startAnimating {
    if (animating) return;
    animating = YES;
    
    [self registerForNotificationCenter];
    
    [self addAnimation];
    self.hidden = NO;
}

- (void)stopAnimating {
    if (!animating) return;
    animating = NO;
    
    [self unregisterFromNotificationCenter];
    
    [self removeAnimation];
    self.hidden = YES;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    if (ABS(frame.size.width - frame.size.height) < CGFLOAT_MIN) {
        // Ensure that we have a square frame
        CGFloat s = MIN(frame.size.width, frame.size.height);
        frame.size.width = s;
        frame.size.height = s;
    }
    shapeLayer.frame = frame;
    shapeLayer.path = [self layoutPath].CGPath;
}

- (UIBezierPath *)layoutPath {
    CGFloat width = self.bounds.size.width;
    
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2.0f, width/2.0f) radius:width/2.2f startAngle:0.f endAngle:2.0f*M_PI clockwise:YES];
}

#pragma mark - Animation part

- (void)addAnimation {
    CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    spinAnimation.toValue        = @(1*2*M_PI);
    spinAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    spinAnimation.duration       = 0.7f;
    spinAnimation.repeatCount    = INFINITY;
    [shapeLayer addAnimation:spinAnimation forKey:kKKMLoaderRotationAnimationKey];
    
    if (self.progress > 0) {
        shapeLayer.strokeStart = 0;
        shapeLayer.strokeEnd = MAX(MIN(self.progress, 1.f), 0.f);
    } else {
        CABasicAnimation *sizingAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        sizingAnimation.fromValue = @(1.f);
        sizingAnimation.toValue = @(0.5f);
        sizingAnimation.autoreverses = YES;
        sizingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        sizingAnimation.duration = 0.7f;
        sizingAnimation.repeatCount = INFINITY;
        [shapeLayer addAnimation:sizingAnimation forKey:kKKMLoaderEndPointAnimationKey];
        
        CABasicAnimation *sizingAnimation1 = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        sizingAnimation1.fromValue = @(0.f);
        sizingAnimation1.toValue = @(0.5f);
        sizingAnimation1.autoreverses = YES;
        sizingAnimation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        sizingAnimation1.duration = 0.7f;
        sizingAnimation1.repeatCount = INFINITY;
        [shapeLayer addAnimation:sizingAnimation1 forKey:kKKMLoaderStartPointAnimationKey];
    }
}

- (void)removeAnimation {
    [shapeLayer removeAnimationForKey:kKKMLoaderRotationAnimationKey];
    [shapeLayer removeAnimationForKey:kKKMLoaderEndPointAnimationKey];
    [shapeLayer removeAnimationForKey:kKKMLoaderStartPointAnimationKey];
}

@end
