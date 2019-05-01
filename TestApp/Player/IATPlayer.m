//
//  IATPlayer.m
//  TestApp
//
//  Created by Ivan Alekseev on 5/1/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATPlayer.h"
#import "IATTrack.h"
#import "IATArtist.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

@interface IATPlayer () <AVAudioPlayerDelegate> {
    AVAudioPlayer *player;
}

@end

@implementation IATPlayer

+ (IATPlayer*)shared {
    static IATPlayer *shared;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shared = [[IATPlayer alloc] initPlayer];
    });
    return shared;
}

- (instancetype)initPlayer {
    self = [super init];
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    
    if (sessionError) {
        IATLog(@"AVAudioSession set category error %@", sessionError);
    }
    
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    if (sessionError) {
        IATLog(@"AVAudioSession set active error: %@", sessionError);
    }
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    commandCenter.previousTrackCommand.enabled = YES;
    [commandCenter.previousTrackCommand addTarget:self action:@selector(previousTrack)];
    commandCenter.nextTrackCommand.enabled = YES;
    [commandCenter.nextTrackCommand addTarget:self action:@selector(nextTrack)];
    commandCenter.playCommand.enabled = YES;
    [commandCenter.playCommand addTarget:self action:@selector(playAudio)];
    commandCenter.pauseCommand.enabled = YES;
    [commandCenter.pauseCommand addTarget:self action:@selector(pauseAudio)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMediaServicesReset) name:AVAudioSessionMediaServicesWereResetNotification object:[AVAudioSession sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    _currentSongIndex = -1;
    
    return self;
}

- (void)stop {
    if (player != nil) {
        [player stop];
        player = nil;
    }
    _currentSongIndex = -1;
}

- (void)setCurrentSongIndex:(NSInteger)currentSongIndex {
    if (currentSongIndex == _currentSongIndex) {
        //  nothing to do there
        return;
    }
    
    [self stop];
    
    _currentSongIndex = currentSongIndex;
    //  reset player when current song set
    NSURL *trackURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"Track%i", (int)currentSongIndex%10] withExtension:@"mp3"];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:trackURL error:nil];
    player.delegate = self;
    [player prepareToPlay];
    [self playAudio];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerSwitchedToTrackNumber:)]) {
        [self.delegate playerSwitchedToTrackNumber:currentSongIndex];
    }
}

- (void)updateTrackInfo:(IATTrack *)track {
    NSMutableDictionary* dict1 = [[NSMutableDictionary alloc] initWithDictionary:@{MPNowPlayingInfoPropertyDefaultPlaybackRate : @(1), MPMediaItemPropertyPlaybackDuration : @(player!=nil ? player.duration : track.duration)}];
    dict1[MPMediaItemPropertyTitle] = track.name;
    if (track.artists.count > 0) {
        dict1[MPMediaItemPropertyArtist] = track.artists[0].name;
    }
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = dict1;
}

#pragma mark - Intercations with player

- (void)previousTrack {
    NSInteger newSongIndex = _currentSongIndex-1;
    
    if (newSongIndex < 0) {
        newSongIndex = self.totalNumberOfSongs-1;
    }
    self.currentSongIndex = newSongIndex;
}

- (void)nextTrack {
    NSInteger newSongIndex = _currentSongIndex+1;
    
    if (newSongIndex > self.totalNumberOfSongs - 1) {
        newSongIndex = 0;
    }
    self.currentSongIndex = newSongIndex;
}

- (void)playAudio {
    if (player != nil && !player.isPlaying) {
        [player play];
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerStarted)]) {
            [self.delegate playerStarted];
        }
    }
}

- (void)pauseAudio {
    if (player != nil && player.isPlaying) {
        [player pause];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerPaused)]) {
        [self.delegate playerPaused];
    }
}

- (BOOL)isPlaying {
    return (player != nil && player.isPlaying);
}

- (void)jumpToProgress:(CGFloat)newProgress {
    [player pause];
    player.currentTime = newProgress * player.duration;
    [player play];
}

#pragma mark - Notifications

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            IATLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            IATLog(@"Headphone/Line plugged in");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            IATLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            IATLog(@"Headphone/Line was pulled. Stopping player....");
            [self pauseAudio];
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
}


- (void)handleMediaServicesReset {
    // • No userInfo dictionary for this notification
    // • Handle this notification by fully reconfiguring audio
    [self stop];
    NSInteger currentSongIndex = self.currentSongIndex;
    _currentSongIndex = -1;
    [self setCurrentSongIndex:currentSongIndex];
}

- (void)handleAudioSessionInterruption:(NSNotification*)notification {
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
            // • Audio has stopped, already inactive
            // • Change state of UI, etc., to reflect non-playing state
            IATLog(@"%@", interruptionType);
            [self pauseAudio];
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                // Here you should continue playback.
                [self playAudio];
            }
        } break;
        default:
            break;
    }
}

#pragma mark - Track Details

- (CGFloat)duration {
    if (player == nil) {
        return 0;
    }
    return player.duration;
}

- (CGFloat)currentTime {
    if (player == nil) {
        return 0;
    }
    return player.currentTime;
}

- (CGFloat)progress {
    if (player == nil) {
        return 0;
    }
    return player.currentTime/player.duration;
}

#pragma mark - Player delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [self nextTrack];
    }
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    IATLog(@"Player Decode Error: %@", [error description]);
}

@end
