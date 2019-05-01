//
//  IATAlbumTableViewCell.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/30/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATAlbumTableViewCell.h"
#import "IATDownloadableImageView.h"
#import "IATAlbum.h"
#import "IATArtist.h"
#import "IATFormatter.h"
#import "IATArtistsView.h"

@interface IATAlbumTableViewCell ()

@property (nonatomic, weak) IBOutlet IATDownloadableImageView *icon;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *year;
@property (nonatomic, weak) IBOutlet UILabel *duration;
@property (nonatomic, weak) IBOutlet IATArtistsView *artistsView;

@end

@implementation IATAlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //  customizing selection
    UIView *selectedBg = [[UIView alloc] init];
    selectedBg.backgroundColor = [[UIColor colorFromHex:@"FB583A"] colorWithAlphaComponent:0.25f];
    self.selectedBackgroundView = selectedBg;
}

- (void)updateWithAlbum:(IATAlbum *)album {
    [self.icon setDownloadableImage:album.coverURL];
    self.name.text = album.name;
    if ([album.year integerValue] > 0) {
        self.year.text = [NSString stringWithFormat:@"%@ ", album.year];
    } else {
        self.year.text = @"";
    }
    self.duration.text = [NSString stringWithFormat:@"(%@)", [IATFormatter timeStringFromSeconds:album.duration]];
    [self.artistsView updateWithArtists:album.artists];
}

@end
