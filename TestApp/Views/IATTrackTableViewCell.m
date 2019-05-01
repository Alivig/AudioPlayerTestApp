//
//  IATTrackTableViewCell.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/30/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATTrackTableViewCell.h"
#import "IATDownloadableImageView.h"
#import "IATTrack.h"
#import "IATArtist.h"
#import "IATArtistsView.h"
#import "IATFormatter.h"

@interface IATTrackTableViewCell ()

@property (nonatomic, weak) IBOutlet IATDownloadableImageView *icon;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *year;
@property (nonatomic, weak) IBOutlet UILabel *duration;
@property (nonatomic, weak) IBOutlet IATArtistsView *artistsView;

@end

@implementation IATTrackTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //  customizing selection
    UIView *selectedBg = [[UIView alloc] init];
    selectedBg.backgroundColor = [[UIColor colorFromHex:@"0095E6"] colorWithAlphaComponent:0.25f];
    self.selectedBackgroundView = selectedBg;
}

- (void)updateWithTrack:(IATTrack *)track {
    [self.icon setDownloadableImage:track.coverURL];
    self.name.text = track.name;
    if ([track.year integerValue] > 0) {
        self.year.text = [NSString stringWithFormat:@"%@ ", track.year];
    } else {
        self.year.text = @"";
    }
    self.duration.text = [IATFormatter timeStringFromSeconds:track.duration];
    [self.artistsView updateWithArtists:track.artists];
}

@end
