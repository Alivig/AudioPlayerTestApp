//
//  IATPlayerView.h
//  TestApp
//
//  Created by Ivan Alekseev on 5/1/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IATTrack;

@interface IATPlayerView : UIView

@property (nonatomic) NSOrderedSet<IATTrack*> *tracks;

- (void)playTrackAtIndex:(NSInteger)index;

@end
