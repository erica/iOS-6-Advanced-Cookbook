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
    
	NSString *lorem = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent condimentum justo vestibulum nisl vestibulum sodales. Vestibulum dapibus sagittis elit, id facilisis eros ullamcorper at. \nMorbi consectetur tempor augue at convallis. Fusce diam leo, porta in mollis sed, molestie in dui. \nProin accumsan ante id nunc mollis porttitor. Donec dapibus, nunc vitae consequat sollicitudin, justo enim consequat arcu, a hendrerit velit purus vitae erat. Sed a eros ac elit pulvinar aliquet nec sed quam. Nullam in elit nunc. Integer fringilla orci at enim feugiat et congue ipsum interdum. Mauris elit elit, egestas id fringilla vel, gravida ut orci. Sed mattis risus luctus orci auctor vitae hendrerit est consectetur.";
    
    FancyString *string = [FancyString string];
    string.font = [UIFont fontWithName:@"pirulen" size:12.0f];
    [string appendFormat:@"%@", lorem];
    
    string.paragraphStyle.paragraphSpacing = 10.0f;
    string.paragraphStyle.firstLineHeadIndent = 18.0f;
    [string setAlignment:@"justified"];
    
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