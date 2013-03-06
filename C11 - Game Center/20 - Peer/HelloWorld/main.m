/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "GameKitHelper.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController <GameKitHelperDataDelegate>
@end

@implementation TestBedViewController
{
    GameKitHelper *helper;
}

- (void) connectionEstablished
{
    NSLog(@"Connection was established");
}

- (void) connectionLost
{
    NSLog(@"Connection was lost");
}

- (void) sentData: (NSString *) errorMessage
{
    if (errorMessage)
        NSLog(@"Error receiving data: %@", errorMessage);
}

- (void) receivedData: (NSData *) data
{
    NSLog(@"Received %d bytes of data", data.length);
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    helper = [GameKitHelper helperWithSessionName:@"Testing" delegate:self];
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