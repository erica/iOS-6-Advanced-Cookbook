/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "MarkupHelper.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController
{
    UITextView *textView;
}
@end

@implementation TestBedViewController

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];

    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.editable = NO;
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    
    NSString *baseString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    
    textView.attributedText = [MarkupHelper stringFromMarkup:baseString];
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