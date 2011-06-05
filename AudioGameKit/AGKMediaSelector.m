//
//  AGKMediaSelectorController.m
//  AudioGameKit
//
//  Created by Zac Bowling on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AGKMediaSelector.h"


@implementation AGKMediaSelector
@synthesize delegate=_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _titleLabel.text = @"No song selected";
    _artistLabel.text = @"";
    _durationLabel.text = @"";
    _mediaItem = nil;
    _albumArtImageView.image = nil;
    _playButton.hidden = YES;
    [_exportURL release],_exportURL=nil;
    UITapGestureRecognizer *geature = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectNewSong:)];
    [_albumArtImageView addGestureRecognizer:geature];
    [geature release];
    _albumArtImageView.backgroundColor = [UIColor grayColor];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction) playTouchUp:(id)sender {
    
    if (_exportURL) {
        AGKMediaSession *session = [[AGKMediaSession alloc] init];
        
        NSError *error;
        
        session.player = [[AVAudioPlayer alloc]initWithContentsOfURL:_exportURL error:&error];
        session.player.meteringEnabled = YES;
        [session.player prepareToPlay];
        
        if (error != nil) {
            NSLog(@"unable to create AVAudioPlayer %@", error);
            return;
        }                    
        
        [self.delegate mediaSelector:self didSelectMediaSession:session];
    }
}

- (IBAction) selectNewSong {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc]initWithMediaTypes:MPMediaTypeMusic];
    mediaPicker.allowsPickingMultipleItems = NO;
    mediaPicker.delegate = self;
    mediaPicker.prompt = @"Select the song you want to play with.";
    [self presentModalViewController:mediaPicker animated:YES];
    [mediaPicker release];

}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [_mediaItem release], _mediaItem = nil;
    _playButton.hidden = YES;
    
    _mediaItem = [[mediaItemCollection.items objectAtIndex:mediaItemCollection.count-1] retain];
    [mediaPicker dismissModalViewControllerAnimated:YES];
    
    MPMediaItemArtwork *artwork = [_mediaItem valueForKey:MPMediaItemPropertyArtwork];
    if (artwork)
        _albumArtImageView.image = [artwork imageWithSize:_albumArtImageView.bounds.size];
    else
        _albumArtImageView.image = nil;
    
    NSString *title = [_mediaItem valueForKey:MPMediaItemPropertyTitle];
    _titleLabel.text = title;
    
    NSString *artist = [_mediaItem valueForKey:MPMediaItemPropertyArtist];
    _artistLabel.text = artist;
    
    //NSURL *url = [_mediaItem valueForKey:MPMediaItemPropertyAssetURL];
    
    
    NSURL *url = [_mediaItem valueForKey:MPMediaItemPropertyAssetURL];
    
    if (url)
    {
        AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
        
        NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
        NSString *exportPath = [[documentsDirectoryPath stringByAppendingPathComponent:@"exportfile.m4a"] retain];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
        }
        
        _exportURL = [NSURL fileURLWithPath:exportPath];
        
        exporter.outputURL = _exportURL;
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            int exportStatus = exporter.status;
            switch (exportStatus) {
                case AVAssetExportSessionStatusFailed: {
                    // log error to text view
                    _playButton.hidden = YES;
                    NSError *exportError = exporter.error;
                    NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                    break;
                }
                case AVAssetExportSessionStatusCompleted: {
                    _playButton.hidden = NO;
                    NSLog (@"AVAssetExportSessionStatusCompleted");
                    break;

                }
                case AVAssetExportSessionStatusUnknown: { NSLog (@"AVAssetExportSessionStatusUnknown"); break;}
                case AVAssetExportSessionStatusExporting: { NSLog (@"AVAssetExportSessionStatusExporting"); break;}
                case AVAssetExportSessionStatusCancelled: { NSLog (@"AVAssetExportSessionStatusCancelled"); break;}
                case AVAssetExportSessionStatusWaiting: { NSLog (@"AVAssetExportSessionStatusWaiting"); break;}
                default: { NSLog (@"didn't get export status"); break;}
            }
        }];
    }
    else
    {
        NSLog(@"No media asset URL");
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissModalViewControllerAnimated:YES];
}

@end
