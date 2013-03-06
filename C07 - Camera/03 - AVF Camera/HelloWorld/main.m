/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraImageHelper.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    CameraImageHelper *helper;
}

// Start or Pause
- (void) toggleSession
{
    if (helper.session.isRunning)
    {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Resume", @selector(toggleSession));
        [helper stopRunningSession];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pause", @selector(toggleSession));
        [helper startRunningSession];
    }
}

// Switch between cameras
- (void) switchCameras
{
    // Always reactivate, so the switch is live
    if (!helper.session.isRunning)
        [self toggleSession];
    
    // Perform the switch
    [helper switchCameras];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    
    // Establish the preview session
    helper = [CameraImageHelper helperWithCamera:kCameraBack];
    [helper startRunningSession];
    [helper embedPreviewInView:imageView];
    [helper layoutPreviewInView:imageView];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.view layoutIfNeeded];
    [helper layoutPreviewInView:imageView];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Switch between cameras
    if ([CameraImageHelper numberOfCameras] > 1)
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Switch", @selector(switchCameras));
    
    // Start or Pause
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pause", @selector(toggleSession));
    
    // The image view holds the live preview
    imageView = [[UIImageView alloc] init];
    [self.view addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    STRETCH_VIEW(self.view, imageView);
    imageView.contentMode = UIViewContentModeCenter;
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