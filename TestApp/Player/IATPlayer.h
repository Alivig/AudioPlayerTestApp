//
//  IATPlayer.h
//  TestApp
//
//  Created by Ivan Alekseev on 5/1/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IATTrack;

@protocol IATPlayerDelegate <NSObject>

- (void)playerSwitchedToTrackNumber:(NSInteger)number;
- (void)playerStarted;
- (void)playerPaused;

@end

@interface IATPlayer : NSObject

+ (IATPlayer*)shared;

//  used to identify and switch between songs
@property (nonatomic) NSInteger currentSongIndex;
//  used for looping playlist
@property (nonatomic) NSInteger totalNumberOfSongs;

//  used to display and track progress
@property (nonatomic, readonly) CGFloat duration;   //  overall song duration
@property (nonatomic, readonly) CGFloat currentTime;    //  progress in seconds
@property (nonatomic, readonly) CGFloat progress;   //  current progress percents

//  returns YES if song is playing right now
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;

@property (nonatomic, weak) NSObject <IATPlayerDelegate> *delegate;

//  methods for controlling playback
- (void)previousTrack;  //  switch to previous track by index
- (void)nextTrack;  //  switch to next track by index
- (void)playAudio;  //  play
- (void)pauseAudio; //  pause
- (void)stop;   //  stops the player and invalidates player
- (void)jumpToProgress:(CGFloat)newProgress;    //  new progress should be in [0 .. 1] area

//  used to update remote control UI
- (void)updateTrackInfo:(IATTrack*)track;

@end
