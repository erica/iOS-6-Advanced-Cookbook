/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIDevice-Hardware.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIDevice *device = [UIDevice currentDevice];
    NSLog(@"Platform: %@", device.platform);
    NSLog(@"HWModel: %@", device.hwmodel);
    NSLog(@"Platform type: %d", device.platformType);
    NSLog(@"Platform string: %@", device.platformString);
    NSLog(@"CPU Freq: %d", device.cpuFrequency);
    NSLog(@"CPU Count: %d", device.cpuCount);
    NSLog(@"Total memory: %ud", device.totalMemory);
    NSLog(@"Mac address: %@", device.macaddress);
    NSLog(@"Retina display: %d", device.hasRetinaDisplay);
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end
@implementation TestBedAppDelegate
{
	UIWindow *window;
}
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