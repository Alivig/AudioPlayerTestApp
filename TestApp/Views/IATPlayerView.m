//
//  IATPlayerView.m
//  TestApp
//
//  Created by Ivan Alekseev on 5/1/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATPlayerView.h"
#import "IATPlayer.h"
#import "IATTrack.h"
#import "IATArtistsView.h"
#import "IATSlider.h"
#import "IATFormatter.h"
#import "IATDownloadableImageView.h"

@interface IATPlayerView () <IATPlayerDelegate> {
    NSInteger currentTrackIndex;
    NSTimer *ticker;
}

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UILabel *timeElapsed;
@property (nonatomic, weak) IBOutlet UILabel *timeRemaining;
@property (nonatomic, weak) IBOutlet IATSlider *progressSlider;

@property (nonatomic, weak) IBOutlet UIView *trackView;
@property (nonatomic, weak) IBOutlet UILabel *trackName;
@property (nonatomic, weak) IBOutlet IATDownloadableImageView *trackIcon;
@property (nonatomic, weak) IBOutlet IATArtistsView *artistsView;

@end

@implementation IATPlayerView

- (void)awakeFromNib {
    [super awakeFromNib];
    currentTrackIndex = -1;
    
    ticker = [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    
    [IATPlayer shared].delegate = self;
}

- (void)removeFromSuperview {
    [ticker invalidate];
    ticker = nil;
    [super removeFromSuperview];
}

- (void)setTracks:(NSOrderedSet<IATTrack*>*)tracks {
    _tracks = tracks;
    [IATPlayer shared].totalNumberOfSongs = tracks.count;
    currentTrackIndex = -1;
    [[IATPlayer shared] stop];
}

- (void)playTrackAtIndex:(NSInteger)index {
    [IATPlayer shared].currentSongIndex = index;
}

- (void)updateUIForIndex:(NSInteger)index {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2f;
    if (currentTrackIndex == index) {
        transition.type = kCATransitionFade;
    } else {
        transition.type = kCATransitionPush;
        transition.subtype = index > currentTrackIndex ? kCATransitionFromRight : kCATransitionFromLeft;
    }
    [self.trackView.layer addAnimation:transition forKey:@"transition"];
    
    self.trackName.text = _tracks[index].name;
    [self.trackIcon setDownloadableImage:_tracks[index].coverURL];
    [self.artistsView updateWithArtists:_tracks[index].artists];
    
    currentTrackIndex = index;
}

- (void)updateProgress {
    self.timeElapsed.text = [IATFormatter timeStringFromSeconds:[IATPlayer shared].currentTime];
    self.timeRemaining.text = [IATFormatter timeStringFromSeconds:[IATPlayer shared].duration-[IATPlayer shared].currentTime];
    
    if (self.progressSlider.isDraging) {
        return;
    }
    self.progressSlider.currentValue = [IATPlayer shared].progress;
}

#pragma mark - Actions

- (IBAction)progressSliderChangedValue:(IATSlider*)slider {
    [[IATPlayer shared] jumpToProgress:slider.currentValue];
    [self updateProgress];
}

- (IBAction)nextTrack:(id)sender {
    [[IATPlayer shared] nextTrack];
}

- (IBAction)previousTrack:(id)sender {
    [[IATPlayer shared] previousTrack];
}

- (IBAction)playOrPause:(id)sender {
    if ([IATPlayer shared].isPlaying) {
        [[IATPlayer shared] pauseAudio];
    } else {
        [[IATPlayer shared] playAudio];
    }
}

#pragma mark - Player delegate

- (void)playerSwitchedToTrackNumber:(NSInteger)number {
    //  animate track changes
    [self updateUIForIndex:number];
}

- (void)playerStarted {
    [self.playButton setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
    self.playButton.imageEdgeInsets = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
}

- (void)playerPaused {
    [self.playButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    self.playButton.imageEdgeInsets = UIEdgeInsetsMake(0.f, 4.f, 0.f, 0.f);
}

@end
