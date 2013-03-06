/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UISwitch *lightSwitch;
    AVCaptureDevice *device;
}

- (void) toggleLightSwitch
{
    // Lock the device
    if ([device lockForConfiguration:nil])
    {
        // Toggle the light on or off
        device.torchMode = (lightSwitch.isOn) ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;

        // Unlock and proceed
        [device unlockForConfiguration];
    }
}

- (BOOL) supportsTorchMode
{
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *aDevice in devices)
    {
        if ((aDevice.hasTorch) && [aDevice isTorchModeSupported:AVCaptureTorchModeOn])
        {
            device = aDevice;
             return YES;
        }
    }

    return NO;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    lightSwitch = [[UISwitch alloc] init];
    [self.view addSubview:lightSwitch];
    PREPCONSTRAINTS(lightSwitch);
    CENTER_VIEW(self.view, lightSwitch);
    CALLBACK_PRESS(lightSwitch, @selector(toggleLightSwitch));
    
    lightSwitch.alpha = 0.0f;
    if ([self supportsTorchMode])
        lightSwitch.alpha = 1.0f;
    else
        self.title = @"Flash/Torch not available";
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