//
//  AGKMediaSelectorController.h
//  AudioGameKit
//
//  Created by Zac Bowling on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "AGKMediaSession.h"

@class AGKMediaSelector;

@protocol AGKMediaSelectorDelegate <NSObject>

- (void) mediaSelector:(AGKMediaSelector *)selector didSelectMediaSession:(AGKMediaSession *) session;
- (void) mediaSelectorDidCancel:(AGKMediaSelector *)selector;

@end

@interface AGKMediaSelector : UIViewController<MPMediaPickerControllerDelegate> {
    id<AGKMediaSelectorDelegate> _delegate;
    IBOutlet UILabel *_titleLabel;
    IBOutlet UILabel *_artistLabel;
    IBOutlet UILabel *_durationLabel;
    IBOutlet UIImageView *_albumArtImageView;
    IBOutlet UIButton *_playButton;
    IBOutlet UIProgressView *_progressView;
    MPMediaItem *_mediaItem;
    NSURL *_exportURL;
    MPMediaPickerController *mediaPicker;
}

@property (assign,nonatomic) id<AGKMediaSelectorDelegate> delegate;

- (IBAction) selectNewSong;

- (IBAction) playTouchUp:(id)sender;


@end
