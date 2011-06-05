//
//  AGKMediaSession.h
//  AudioGameKit
//
//  Created by Zac Bowling on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AGKMediaSession;

@protocol AGKMediaSessionDelegate <NSObject>


- (void)mediaSessionDidStart:(AGKMediaSession *)session;
- (void)mediaSessionDidEnd:(AGKMediaSession *)session;

- (void)mediaSessionBeginInteruption:(AGKMediaSession *)session;
- (void)mediaSessionEndInteruption:(AGKMediaSession *)session;

- (void)mediaSession:(AGKMediaSession *)session max:(float)max average:(float)average;

@optional 
- (BOOL)mediaSessionWillStart:(AGKMediaSession *)session; //return false to stop playback

@end

@interface AGKMediaSession : NSObject<AVAudioPlayerDelegate> {
    id<AGKMediaSessionDelegate> _delegate;  
    AVAudioPlayer *_player;
    NSTimer *_playbackTimer;
}

//this will not be here in the next version
@property (retain, nonatomic) AVAudioPlayer *player;

@property (assign, nonatomic) id<AGKMediaSessionDelegate> delegate;

@property (readonly, assign) NSTimeInterval currentTime;

@property (readonly, assign) NSTimeInterval duration;

- (void) play;
- (void) pause;


@end
