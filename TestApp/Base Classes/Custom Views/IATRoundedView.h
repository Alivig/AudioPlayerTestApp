//
//  IATRoundedView.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/26/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface IATRoundedView : UIView

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, copy) IBInspectable UIColor *borderColor;

@end
