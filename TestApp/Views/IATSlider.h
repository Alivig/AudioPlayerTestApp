//
//  IATSlider.h
//  TestApp
//
//  Created by Ivan Alekseev on 5/1/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface IATSlider : UIControl

@property (nonatomic, copy) IBInspectable UIColor *backgroundColor;
@property (nonatomic, copy) IBInspectable UIColor *activeColor;
@property (nonatomic, assign) IBInspectable CGFloat barWidth;
@property (nonatomic, assign) IBInspectable CGFloat thumbSize;

@property (nonatomic, assign) IBInspectable CGFloat minValue;
@property (nonatomic, assign) IBInspectable CGFloat maxValue;
@property (nonatomic, assign) IBInspectable CGFloat currentValue;

@property (nonatomic, readonly) BOOL isDraging;

@end
