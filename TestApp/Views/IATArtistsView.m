//
//  IATArtistsView.m
//  TestApp
//
//  Created by Ivan Alekseev on 4/30/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATArtistsView.h"
#import "IATDownloadableImageView.h"
#import "IATArtist.h"

static UIColor * mainColor;
static UIColor * secondaryColor;

@interface IATArtistsView ()

@property (nonatomic, strong) IBOutletCollection(IATDownloadableImageView) NSArray *portraits;
@property (nonatomic, weak) IBOutlet UILabel *names;

@end

@implementation IATArtistsView

+ (void)initialize {
    [super initialize];
    mainColor = [UIColor colorWithWhite:0.f alpha:1.f];
    secondaryColor = [UIColor colorWithWhite:0.8f alpha:1.f];
}

- (void)updateWithArtists:(NSOrderedSet <IATArtist*>*)artists {
    //  populate names and portraits
    NSMutableAttributedString *artistsString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSInteger portraitsCounter = 0;
    for (IATArtist *artist in artists) {
        //  add artist name to names string
        NSAttributedString *name;
        if (artist == artists.firstObject) {
            name = [[NSAttributedString alloc] initWithString:artist.name attributes:@{NSForegroundColorAttributeName:mainColor}];
        } else {
            name = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@", %@", artist.name] attributes:@{NSForegroundColorAttributeName:secondaryColor}];
        }
        [artistsString appendAttributedString:name];
        
        //  check if there is any available portraits
        if (portraitsCounter < self.portraits.count) {
            IATDownloadableImageView *portrait = (IATDownloadableImageView*)self.portraits[portraitsCounter];
            if (artist.coverURL != nil) {
                [portrait setDownloadableImage:artist.coverURL];
            } else {
                portrait.image = nil;
            }
            portrait.hidden = NO;
        }
        //  increase counter for portraits
        portraitsCounter++;
    }
    
    //  hide all not used portraits
    while (portraitsCounter < self.portraits.count) {
        IATDownloadableImageView *portrait = (IATDownloadableImageView*)self.portraits[portraitsCounter];
        portrait.image = nil;
        portrait.hidden = YES;
        portraitsCounter++;
    }
    
    //  set names string
    self.names.attributedText = artistsString;
}

@end
