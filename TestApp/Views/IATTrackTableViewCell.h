//
//  IATTrackTableViewCell.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/30/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IATTrack;

static NSString *cellIdentifier = @"IATTrackTableViewCell";

@interface IATTrackTableViewCell : UITableViewCell

- (void)updateWithTrack:(IATTrack*)track;

@end
