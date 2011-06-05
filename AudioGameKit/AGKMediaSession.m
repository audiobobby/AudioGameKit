//
//  AGKMediaSession.m
//  AudioGameKit
//
//  Created by Zac Bowling on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AGKMediaSession.h"



@implementation AGKMediaSession
@synthesize delegate=_delegate;
@synthesize player=_player;
@dynamic currentTime;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (AVAudioPlayer *)player {
    return [[_player autorelease] retain];
}

- (void)setPlayer:(AVAudioPlayer *)player {
    
    [_player autorelease];
    _player = nil;
    
    if (player){
        _player = [player retain];
    }
}

- (void)stopTimer {
    if (_playbackTimer){
        [_playbackTimer invalidate];
        [_playbackTimer release],_playbackTimer=nil;
    }
}

- (void)startTimer {
    if (!_playbackTimer){
        _playbackTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2
                                                        target:self 
                                                         selector:@selector(tick:) 
                                                      userInfo:nil 
                                                       repeats:YES] retain];
    }
}

- (void) tick: (NSTimer*)timer {
    [self.player updateMeters];
    int chans = self.player.numberOfChannels;
    
    float cavg;
    float cpeak;
    
    


    for (int i =0; i<chans; i++)
    {    
        cavg += [self.player averagePowerForChannel:i];
        cpeak += [self.player peakPowerForChannel:i];
    }
    
    cavg = cavg/(float)chans;
    cpeak = cpeak/(float)chans;
    
    [self.delegate mediaSession:self max:cpeak average:cavg];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.delegate mediaSessionDidEnd:self];
    [self stopTimer];
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"encoder error %@", error);
    [self.delegate mediaSessionDidEnd:self];
    [self stopTimer];
}

/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    [self.delegate mediaSessionBeginInteruption:self];
    [self stopTimer];
}

/* audioPlayerEndInterruption:withFlags: is called when the audio session interruption has ended and this player had been interrupted while playing. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags {
    [self.delegate mediaSessionEndInteruption:self];
    if (flags & AVAudioSessionInterruptionFlags_ShouldResume)
    {
        [self play];
    }
}

- (NSTimeInterval) duration {
    if (self.player)
        return self.player.duration;
    return 0;
}

- (NSTimeInterval) currentTime {
    if (self.player)
        return self.player.currentTime;
    return 0;
}

- (void) play {
    if (!self.player) 
    {
        [self stopTimer];
        return; 
    }
    
    [self startTimer];
    if ([self.delegate respondsToSelector:@selector(mediaSessionWillStart:)])
    {
        BOOL shouldplay = [self.delegate mediaSessionWillStart:self];
        if (!shouldplay) return;
    }
    
    self.player.numberOfLoops = -1; //forever
    
    [self.player play];
    [self.delegate mediaSessionDidStart:self];
}

- (void) pause {
    [self stopTimer];
    if (!self.player) 
    {
        return; 
    }
    [self.player pause];
}

- (void) dealloc {
    [_playbackTimer release];
    [_player release];
    [super dealloc];
}

@end
