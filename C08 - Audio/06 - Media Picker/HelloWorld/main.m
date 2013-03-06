/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TestBedViewController : UIViewController <MPMediaPickerControllerDelegate, UIPopoverControllerDelegate>
@end

@implementation TestBedViewController
{
    UIPopoverController *popover;
}

#pragma mark - Utility
- (void) performDismiss
{
    if (IS_IPHONE)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [popover dismissPopoverAnimated:YES];
}

- (void) presentViewController:(UIViewController *)viewControllerToPresent
{
    if (IS_IPHONE)
	{
        [self presentViewController:viewControllerToPresent animated:YES completion:nil];
	}
	else
	{
        popover = [[UIPopoverController alloc] initWithContentViewController:viewControllerToPresent];
        popover.delegate = self;
        [popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

// Popover was dismissed
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController
{
    popover = nil;
}

#pragma mark Media Picker
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
	for (MPMediaItem *item in [mediaItemCollection items])
		NSLog(@"[%@] %@", [item valueForProperty:MPMediaItemPropertyArtist], [item valueForProperty:MPMediaItemPropertyTitle]);
    [self performDismiss];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
	if (IS_IPHONE)
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) action
{
	MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
	mpc.delegate = self;
	mpc.prompt = @"Please select an item";
	mpc.allowsPickingMultipleItems = YES;
    [self presentViewController:mpc];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
#if TARGET_IPHONE_SIMULATOR
    self.title = @"Recipe requires device";
#else
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action));
#endif
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