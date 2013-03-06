/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Utility.h"
#import "ModalAlertDelegate.h"

@interface TestBedViewController : UIViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
@end

@implementation TestBedViewController
{
    IBOutlet UIView *controlView;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
	NSTimer *timer;
    
    // Outlets
	IBOutlet UIProgressView *meter1;
	IBOutlet UIProgressView *meter2;
}

- (void) viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:controlView];
    PREPCONSTRAINTS(controlView);
    STRETCH_VIEW(self.view, controlView);
    
    if ([self startAudioSession])
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Record", @selector(record));
	else
		self.title = @"No Audio Input Available";
}

- (NSString *) dateString
{
	// return a formatted string for a file name
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"ddMMMYY_hhmmssa";
	return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".aif"];
}

- (NSString *) formatTime: (int) num
{
	// return a formatted ellapsed time string
	int secs = num % 60;
	int min = num / 60;
	if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
	return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}

- (void) updateMeters
{
	// Show the current power levels
	[recorder updateMeters];

    // Show average and peak values on the two meters
	meter1.progress = pow(10, 0.05f * [recorder averagePowerForChannel:0]);
	meter2.progress = pow(10, 0.05f * [recorder peakPowerForChannel:0]);
    
	// Update the current recording time
	self.title = [NSString stringWithFormat:@"%@", [self formatTime:recorder.currentTime]];
}

- (void) say: (NSString *) aString
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:aString message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:alertView];
    [delegate show];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	// Prepare UI for recording
	self.title = nil;
	meter1.hidden = NO;
	meter2.hidden = NO;
	{
		// Return to play and record session
		NSError *error;
		if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
		{
			NSLog(@"Error: %@", error.localizedFailureReason);
			return;
		}
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Record", @selector(record));
	}
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)aRecorder successfully:(BOOL)flag
{
	// Stop monitoring levels, time
	[timer invalidate];
	meter1.progress = 0.0f;
	meter1.hidden = YES;
	meter2.progress = 0.0f;
	meter2.hidden = YES;
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
    
    if (!flag)
        NSLog(@"Recording was flagged as unsuccessful");
    
    NSURL *url = recorder.url;
    NSString *result = [NSString stringWithFormat:@"File saved to %@", [url.path lastPathComponent]];
	[self say:result];
    
    NSError *error;
	
	// Start playback
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!player)
    {
        NSLog(@"Error establishing player for %@: %@", recorder.url, error.localizedFailureReason);
        return;
    }
	player.delegate = self;
	
	// Change audio session for playback
	if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error])
	{
		NSLog(@"Error updating audio session: %@", error.localizedFailureReason);
		return;
	}
    
	self.title = @"Playing back recording...";
    [player prepareToPlay];
	[player play];
}

- (void) stopRecording
{
	// This causes the didFinishRecording delegate method to fire
	[recorder stop];
}

- (void) continueRecording
{
	// resume from a paused recording
	[recorder record];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(stopRecording));
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, @selector(pauseRecording));
}

- (void) pauseRecording
{
	// pause an ongoing recording
	[recorder pause];
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Continue", @selector(continueRecording));
	self.navigationItem.rightBarButtonItem = nil;
}

#define FILEPATH [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[self dateString]]

- (BOOL) record
{
	NSError *error;
	
	// Recording settings
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    settings[AVFormatIDKey] = @(kAudioFormatLinearPCM);
    settings[AVSampleRateKey] = @(8000.0f);
    settings[AVNumberOfChannelsKey] = @(1); // mono
    settings[AVLinearPCMBitDepthKey] = @(16);
    settings[AVLinearPCMIsBigEndianKey] = @NO;
    settings[AVLinearPCMIsFloatKey] = @NO;
	
	// File URL
	NSURL *url = [NSURL fileURLWithPath:FILEPATH];
	
	// Create recorder
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
	if (!recorder)
	{
		NSLog(@"Error establishing recorder: %@", error.localizedFailureReason);
		return NO;
	}
	
	// Initialize degate, metering, etc.
	recorder.delegate = self;
	recorder.meteringEnabled = YES;
	meter1.progress = 0.0f;
	meter2.progress = 0.0f;
	self.title = @"0:00";
	
	if (![recorder prepareToRecord])
	{
		NSLog(@"Error: Prepare to record failed");
		[self say:@"Error while preparing recording"];
		return NO;
	}
	
	if (![recorder record])
	{
		NSLog(@"Error: Record failed");
		[self say:@"Error while attempting to record audio"];
		return NO;
	}
	
	// Set a timer to monitor levels, current time
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
	
	// Update the navigation bar
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(stopRecording));
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, @selector(pauseRecording));
    
	return YES;
}

- (BOOL) startAudioSession
{
	// Prepare the audio session
	NSError *error;
	AVAudioSession *session = [AVAudioSession sharedInstance];
	
	if (![session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
	{
		NSLog(@"Error setting session category: %@", error.localizedFailureReason);
		return NO;
	}
	
	if (![session setActive:YES error:&error])
	{
		NSLog(@"Error activating audio session: %@", error.localizedFailureReason);
		return NO;
	}
	
	return session.inputAvailable; // used to be inputIsAvailable
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}