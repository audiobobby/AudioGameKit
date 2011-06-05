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
    // Do any additional setup after loading the view from its nib.
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
        
        __block NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
        
        exporter.outputURL = exportURL;
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            int exportStatus = exporter.status;
            switch (exportStatus) {
                case AVAssetExportSessionStatusFailed: {
                    // log error to text view
                    NSError *exportError = exporter.error;
                    NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                    break;
                }
                case AVAssetExportSessionStatusCompleted: {
                    NSLog (@"AVAssetExportSessionStatusCompleted");
                    AGKMediaSession *session = [[AGKMediaSession alloc] init];
                    
                    NSError *error;
                    
                    session.player = [[AVAudioPlayer alloc]initWithContentsOfURL:exportURL error:&error];
                    
                    if (error == nil) {
                        NSLog(@"unable to create AVAudioPlayer %@", error);
                        break;
                    }                    
                
                    [self.delegate mediaSelector:self didSelectMediaSession:session];
                    
                    
                    
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
    
    
    
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissModalViewControllerAnimated:YES];
}

@end
