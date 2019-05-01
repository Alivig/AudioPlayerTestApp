//
//  IATLoader.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface IATLoader : UIView

@property (nonatomic, assign) IBInspectable CGFloat lineWidth;
@property (nonatomic, copy) IBInspectable UIColor *lineColor;
@property (nonatomic, assign) IBInspectable CGFloat progress;   //  used to show progress as loader

@property (nonatomic, readonly) BOOL isAnimating;

- (void)startAnimating;
- (void)stopAnimating;

+ (IATLoader*)showInCenterOfView:(UIView*)v;

@end
