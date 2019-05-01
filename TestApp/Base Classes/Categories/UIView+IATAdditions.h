//
//  UIView+IATAdditions.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (IATAdditions)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat bottom;

@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

@property(nonatomic) CGFloat centerX;
@property(nonatomic) CGFloat centerY;

@property(nonatomic,readonly) CGFloat screenX;
@property(nonatomic,readonly) CGFloat screenY;
@property(nonatomic,readonly) CGFloat screenViewX;
@property(nonatomic,readonly) CGFloat screenViewY;
@property(nonatomic,readonly) CGRect screenFrame;
@property(nonatomic,readonly) CGPoint screenViewCenter;
@property(nonatomic) CGPoint origin;
@property(nonatomic) CGSize size;

@property(nonatomic,readonly) CGPoint centerPoint;

@end
