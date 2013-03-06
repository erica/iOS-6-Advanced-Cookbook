/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "UIDevice-Orientation.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) showOrientation: (NSNotification *) notification
{
    NSString *orientationString = [UIDevice orientationString:[UIDevice currentDevice].acceleratorBasedOrientation];
    NSLog(@"%@", orientationString);
    self.title = orientationString;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(showOrientation:) userInfo:nil repeats:YES];
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