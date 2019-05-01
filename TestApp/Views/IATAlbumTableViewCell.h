//
//  IATAlbumTableViewCell.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/30/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IATAlbum;

static NSString *cellIdentifier = @"IATAlbumTableViewCell";

@interface IATAlbumTableViewCell : UITableViewCell

- (void)updateWithAlbum:(IATAlbum*)album;

@end
