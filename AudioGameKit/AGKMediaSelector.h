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

@class AGKMediaSelector;

@protocol AGKMediaSelectorDelegate <NSObject>

- (void) mediaSelectorController:(AGKMediaSelector *)selector didSelectMediaSession:(AGKMediaSession *) session;
- (void) mediaSelectorDidCancel;

@end

@interface AGKMediaSelector : UIViewController {
    id<AGKMediaSelectorDelegate> _delegate;
}

@property (assign,nonatomic) id<AGKMediaSelectorDelegate> delegate;

@end
