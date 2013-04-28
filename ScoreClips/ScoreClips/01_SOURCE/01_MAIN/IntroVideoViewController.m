//
//  IntroVideoViewController.m
//  VISIKARD
//
//  Created by VisiKard MacBook Pro on 3/18/13.
//
//

#import "IntroVideoViewController.h"
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppViewController.h"
#import "Define.h"

@interface IntroVideoViewController () <APIRequesterProtocol>
{
    MPMoviePlayerController         *player;
    APIRequester                    *_APIRequester;
    int                             _index;
}

@end

@implementation IntroVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _index = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willFinishPlayBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(receivedRotate:) name: UIDeviceOrientationDidChangeNotification object: nil];
    

    NSString *url = [_URLClips objectAtIndex:0];
    NSRange range = NSMakeRange([url length]-4, 4);
    NSString *urlExt = [url substringWithRange: range];
    
    player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
    player.scalingMode = MPMovieScalingModeAspectFit;
    player.controlStyle = MPMovieControlStyleEmbedded;
    
    
    if ([urlExt isEqualToString:@"m3u8"]) {
        [player setMovieSourceType:MPMovieSourceTypeStreaming];
    }
    
    UIView *patternView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    patternView.backgroundColor = [UIColor blackColor];
    [player.backgroundView addSubview:patternView];
    
    [player prepareToPlay];
    [[player view] setFrame:CGRectMake(0, 27, self.view.bounds.size.width, self.view.bounds.size.height-27)]; // size to fit parent view exactly
    [self.view addSubview:[player view]];
    [player play];
    
    [player setFullscreen:YES animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidUnload {
    player = nil;
}

-(IBAction)btnBackAct:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void) willEnterFullscreen: (NSNotification *) notify {
    //    isVideoFullscreen = YES;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown |UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight]
                                                  forKey:STRING_USER_DEFAULT_ORIENTATION];
    }
    
}

- (void) willExitFullscreen: (NSNotification *) notify {
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        self.navigationController.view.transform = CGAffineTransformMakeRotation(0);
    }
    
    self.navigationController.view.bounds = CGRectMake(0.0, 0.0, 320.0, 480.0);
    self.view.bounds = CGRectMake(0.0, 0.0, 320.0,480.0);
    // A trick to hide the rectangle white bar after play fullscreen in ipad
    self.navigationController.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    
    // Default Orientation is Portrait for the whole app
    // Which screen want to support other Orientation just set STRING_USER_DEFAULT_ORIENTATION
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:UIInterfaceOrientationMaskPortrait]
                                              forKey:STRING_USER_DEFAULT_ORIENTATION];
}

- (void) receivedRotate:(NSNotification*) notify {
    
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        player.fullscreen = YES;
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
//        self.navigationController.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.navigationController.view.bounds = CGRectMake(0.0, 0.0, 480.0, 320.0);
        self.view.bounds = CGRectMake(0.0, 0.0, 480.0, 320.0);
    } else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        player.fullscreen = YES;
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
//        self.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.navigationController.view.bounds = CGRectMake(0.0, 0.0, 480.0, 320.0);
        self.view.bounds = CGRectMake(0.0, 0.0, 480.0, 320.0);
    }
}

- (void) playbackStateChanged:(NSNotification*) aNotification {
    
    MPMoviePlayerController *moviePlayer = aNotification.object;
    MPMoviePlaybackState playbackState = moviePlayer.playbackState;
    NSLog(@"playbackStateChanged: %i----%f",playbackState,player.currentPlaybackRate);

//    // Obtain the reason why the movie playback finished
//    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
//    
//    NSLog(@"finishReason: %i----%i",[finishReason intValue],player.playbackState);
//    if (player.playbackState == MPMoviePlaybackStatePlaying) {
//        //isVideoPlaying = YES;
//    } else {
//        if (player.playbackState == MPMoviePlaybackStatePaused) {
//            //VKLog(@"video is paused");
//        } else {
//            //isVideoPlaying = NO;
//            //if (isVideoFullscreen == NO) {
//            //    [self removeMoviePlayer];
//           //}
//        }
//    }
}

- (void) willFinishPlayBack:(NSNotification*) aNotification {
    // check current play list to play next clip
    if (_index + 1 < [_URLClips count]) {
        // automatic run the next clip
        _index++;
        NSString *url = [_URLClips objectAtIndex:_index];
        [player setContentURL:[NSURL URLWithString:url]];
        [player prepareToPlay];
        [player play];
    }
}



@end
