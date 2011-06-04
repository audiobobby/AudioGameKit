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

- (void)mediaSessionDidEnd:(AGKMediaSession *)session;
- (void)mediaSessionDidStart:(AGKMediaSession *)session;
- (void)mediaSession:(AGKMediaSession *)session sampleData:(NSArray *)data;

@end

@interface AGKMediaSession : NSObject {
    id<AGKMediaSessionDelegate> _delegate;  
    
}

@property (assign, nonatomic) id<AGKMediaSessionDelegate> delegate;

@property (readonly, assign) NSInteger time;



@end
