/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Utility.h"
#import "ModalSheetDelegate.h"

@interface TestBedViewController : UIViewController <AVAudioPlayerDelegate>
@end

@implementation TestBedViewController
{
	AVAudioPlayer *player;
}

- (BOOL) prepAudio
{
	NSError *error;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"MeetMeInSt.Louis1904" ofType:@"mp3"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;
	
	// Initialize the player
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
	player.delegate = self;
	if (!player)
	{
		NSLog(@"Could not establish player: %@", error.localizedFailureReason);
		return NO;
	}
	
	[player prepareToPlay];
    
	return YES;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)aPlayer successfully:(BOOL)flag
{
	// just keep playing
	[player play];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)aPlayer
{
	// perform any interruption handling here
	printf("Interruption Detected\n");
	[[NSUserDefaults standardUserDefaults] setFloat:[player currentTime] forKey:@"Interruption"];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)aPlayer
{
	// resume playback at the end of the interruption
	printf("Interruption ended\n");
	[player play];
	
	// remove the interruption key. it won't be needed
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Interruption"];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self prepAudio];
    // Check for previous interruption
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Interruption"])
	{
		player.currentTime = [[NSUserDefaults standardUserDefaults] floatForKey:@"Interruption"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Interruption"];
	}
	
	// Start playback
	[player play];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
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