/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Recorder.h"
#import "LibraryController.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
@end

@implementation TestBedViewController
{
    UIProgressView *power;
    UIButton *button;
    
    BOOL isRecording;
    Recorder *recorder;
    NSTimer *timer;
}

- (NSString *) dateString
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"ddMMMYY_hhmmssa";
	return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".aif"];
}

- (void) setButtonArt: (NSString *) baseArt
{
    NSString *normal = [NSString stringWithFormat:@"%@.png", baseArt];
    NSString *highlight = [NSString stringWithFormat:@"%@2.png", baseArt];
    
    [button setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlight] forState:UIControlStateHighlighted];
}

- (void) library: (UIBarButtonItem *) bbi
{
	// stop any current recording
	if (isRecording)
	{
        [self setButtonArt:@"green"];
		self.navigationItem.leftBarButtonItem = nil;
		[recorder stopRecording];
		recorder = nil;
		self.title = nil;
		isRecording = NO;
	}
	
	// stop power monitoring
	[timer invalidate];
	timer = nil;
	
	// push the library controller
	[self.navigationController pushViewController:[[LibraryController alloc] init] animated:YES];
}

- (NSString *) formatTime: (int) num
{
	int secs = num % 60;
	int min = num / 60;
	
	if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
	
	return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}

- (void) updateStatus
{
	power.progress = recorder.averagePower;
	self.title = [self formatTime:recorder.currentTime];
}

#define FILEPATH [DOCUMENTS_FOLDER stringByAppendingPathComponent:[self dateString]]

- (void) buttonPushed
{
	// Establish recorder
	if (!recorder)
        recorder = [[Recorder alloc] init];
    
	if (!recorder)
	{
		NSLog(@"Error: Could not create recorder");
		return;
	}
	
	if (!isRecording)
	{
		BOOL success = [recorder startRecording:FILEPATH];
		if (!success)
		{
			printf("Error starting recording\n");
			[recorder stopRecording];
			recorder = nil;
			isRecording = NO;
			return;
		}
	}
	else
	{
		[recorder stopRecording];
		recorder = nil;
		self.title = nil;
	}
	
	isRecording = !isRecording;
    
	// Handle the GUI updates
	if (isRecording)
	{
		// start monitoring the power level
		timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateStatus) userInfo:nil repeats:YES];
        [self setButtonArt:@"red"];
		self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, @selector(pauseRecording));
	}
	else
	{
		// Stop monitoring the power level
		power.progress = 0.0f;
		[timer invalidate];
		timer = nil;
		
        [self setButtonArt:@"green"];
		self.navigationItem.leftBarButtonItem = nil;
	}
}

- (void) resumeRecording
{
	if (recorder && recorder.isRecording)
	{
		[recorder resume];
		self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, @selector(pauseRecording));
	}
}

- (void) pauseRecording
{
	if (recorder && recorder.isRecording)
	{
		[recorder pause];
		self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPlay, @selector(resumeRecording));
	}
}


- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Library", @selector(library:));
    
    power = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self.view addSubview:power];
    PREPCONSTRAINTS(power);
    CONSTRAIN(self.view, power, @"V:|-[power]");
    CONSTRAIN(self.view, power, @"H:|-[power]-|");
    
    button = [[UIButton alloc] initWithFrame:(CGRect){.size = CGSizeMake(320.0f, 320.0f)}];
    [button addTarget:self action:@selector(buttonPushed) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonArt:@"green"];
    [self.view addSubview:button];
    PREPCONSTRAINTS(button);
    CONSTRAIN(self.view, button, @"V:|-40-[button]");
    CENTER_VIEW_H(self.view, button);
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