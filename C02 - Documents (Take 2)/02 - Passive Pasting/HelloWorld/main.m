/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UTIHelper.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController <UITextViewDelegate>
@end

@implementation TestBedViewController 
{
    UITextView *textView;
    BOOL enableWatcher;
}

- (void) updatePasteboard
{
    if (enableWatcher)
        [UIPasteboard generalPasteboard].string = textView.text;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updatePasteboard];
}

- (void) toggle: (UIBarButtonItem *) bbi
{
    enableWatcher = !enableWatcher;
    bbi.title = enableWatcher ? @"Stop Watching" : @"Watch";
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.delegate = self;
    [self updatePasteboard];
    [self.view addSubview:textView];
    
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Watch", @selector(toggle:));
    
    NSLog(@"%@", conformanceArray(allUTIsForExtension(@"JPEG")[0]));
}
@end

#pragma mark - Application Setup -
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