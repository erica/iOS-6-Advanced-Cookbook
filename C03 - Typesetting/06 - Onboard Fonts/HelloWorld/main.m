/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "FancyString.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController
{
    UITextView *textView;
    FancyString *string;
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
    
    string = [FancyString string];
    string.ignoreTraits = YES;
    
    UIFont *headerFont = [UIFont fontWithName:@"Futura" size:24.0f];
    UIFont *familyFont = [UIFont fontWithName:@"Futura" size:18.0f];
    
    for (NSString *familyName in [UIFont familyNames])
    {
        string.font = headerFont;
        string.foregroundColor = [UIColor redColor];
        [string appendFormat:@"\u25BC  %@\n", familyName];

        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName])
        {
            string.font = familyFont;
            string.foregroundColor = nil;
            [string appendFormat:@"\t\u25A0 %@:  ", fontName];
            string.font = [UIFont fontWithName:fontName size:18.0f];
            string.foregroundColor = [UIColor darkGrayColor];
            [string appendFormat:@"The Quick Brown Fox Jumps Over the Lazy Dog.\n"];
        }
        
        [string appendFormat:@"\n"];
    }
    
    textView.attributedText = string.string;
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