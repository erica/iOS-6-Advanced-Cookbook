/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "WebHelper.h"
#import "UIDevice-Reachability.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UITextView *textView;
    WebHelper *helper;
}

- (void) serviceCouldNotBeEstablished
{
    textView.text = @"Service could not be established. Sorry.";
}

- (void) serviceWasEstablished: (WebHelper *) aHelper
{
    NSString *status = [NSString stringWithFormat:@"Service established. Connect to http://%@:%d", [UIDevice currentDevice].hostname, aHelper.activePort];
    textView.text = status;
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(disconnect));
}

- (void) serviceWasLost
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start serving", @selector(serve));
    textView.text = @"Press the button to start serving";
}

- (void) serviceDidEnd
{
    [self serviceWasLost];
}

- (void) disconnect
{
    [helper stopService];
}

- (void) serve
{
	self.navigationItem.rightBarButtonItem = nil;
    helper = [WebHelper serviceWithDelegate:self];
}

- (UIImage *) image
{
    return blockImage(180.0f);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start Server", @selector(serve));
    
    textView = [[UITextView alloc] init];
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Futura" size:18.0f];
    
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
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