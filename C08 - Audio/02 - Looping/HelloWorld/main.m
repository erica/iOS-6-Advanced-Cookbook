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
	// Check for the file. "Drumskul" was released as a public domain audio loop on archive.org as part of "loops2try2".
	NSError *error;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"loop" ofType:@"mp3"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;
	
	// Initialize the player
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
	if (!player)
	{
		NSLog(@"Could not establish AV Player: %@", error.localizedFailureReason);
		return NO;
	}
	
	// Prepare the player and set the loops to, basically, unlimited
	[player prepareToPlay];
	[player setNumberOfLoops:999999];
    
	return YES;
}

- (void) fadeIn
{
    player.volume = MIN(player.volume + 0.05f, 1.0f);
    if (player.volume < 1.0f)
        [self performSelector:@selector(fadeIn) withObject:nil afterDelay:0.1f];
}

- (void) fadeOut
{
    player.volume = MAX(player.volume - 0.1f, 0.0f);
    if (player.volume > 0.05f)
        [self performSelector:@selector(fadeOut) withObject:nil afterDelay:0.1f];
    else
        [player pause];
}


- (void) viewDidAppear: (BOOL) animated
{
	// Start playing at no-volume
	player.volume = 0.0f;
	[player play];
	
	// fade in the audio over a second
    [self fadeIn];
	
	// Add the push button
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void) viewWillDisappear: (BOOL) animated
{
	// fade out the audio over a second
    [self fadeOut];
}

- (void) push
{
	// Disable the now-pressed right-button
	self.navigationItem.rightBarButtonItem.enabled = NO;

	// Create a simple new view controller
	UIViewController *vc = [[UIViewController alloc] init];
	vc.view.backgroundColor = [UIColor whiteColor];
	vc.title = @"No Sounds";
    
	// Push the new view controller
	[self.navigationController pushViewController:vc animated:YES];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Push", @selector(push));
    self.title = @"Looped Sounds";
    [self prepAudio];
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