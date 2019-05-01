//
//  IATCustomButton.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface IATCustomButton : UIButton

@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, copy) IBInspectable UIColor *normalBorderColor;
@property (nonatomic, copy) IBInspectable UIColor *highlightedBorderColor;
@property (nonatomic, copy) IBInspectable UIColor *disabledBorderColor;

- (void)showLoadingIndicator;
- (void)showLoadingIndicatorCentered;
- (void)showLoadingIndicator:(UIColor*)indicatorColor;
- (void)showLoadingIndicatorCentered:(UIColor*)indicatorColor;
- (void)hideLoadingIndicator;

@end
