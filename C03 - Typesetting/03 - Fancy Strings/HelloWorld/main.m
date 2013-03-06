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
    
    // Establish our baseline
    [string setAlignment:@"center"];
    string.font = [UIFont fontWithName:@"Arial" size:24.0f];
    
    
    // Header
    [string performTransientAttributeBlock:^(){
        string.bold = YES;
        string.font = [UIFont fontWithName:@"Georgia" size:32.0f];
        [string appendFormat:@"HELLO WORLD!"];
    }];


    // Italics and Bold
    [string performTransientAttributeBlock:^(){
         string.italic = YES;
        [string appendFormat:@"\n\nItalic. "];
        string.italic = NO;
        string.bold = YES;
        [string appendFormat:@"Bold. "];
    }];
     
    // Colors, Stroke Width
    [string performTransientAttributeBlock:^(){
        string.foregroundColor = [UIColor redColor];
        string.bold = YES;
        [string appendFormat:@"This is red and bold. "];
        [string performTransientAttributeBlock:^(){
            string.font = [UIFont fontWithName:@"Georgia" size:24.0f];
            string.bold = NO;
            string.underline = YES;
            string.strokeColor = [UIColor greenColor];
            string.strokeWidth = 2.0f;
            [string appendFormat:@"This is Green Georgia Outline, Underlined Not Bolded. "];
        }];
        string.bold = NO;
        string.foregroundColor = COOKBOOK_PURPLE_COLOR;
        [string appendFormat:@"And this is not green *or* bolded.\n\n"];
    }];
    
    [string appendFormat:@"Back to the original attributes.\n"];
    
    // Foreground, Background
    [string performTransientAttributeBlock:^(){
        string.backgroundColor = [UIColor redColor];
        [string appendFormat:@"Red background"];
        string.backgroundColor = [UIColor greenColor];
        [string appendFormat:@"Green background"];
        string.backgroundColor = nil;
        [string appendFormat:@"No Background\n\n"];
    }];
    
    // Styles
    [string performTransientAttributeBlock:^(){
        string.strikethrough = YES;
        [string appendFormat:@"Strikethrough "];
        string.strikethrough = NO;

        string.underline = YES;
        [string appendFormat:@"underline "];
        string.underline = NO;

        string.bold = YES;
        [string appendFormat:@"bold "];
        string.bold = NO;

        string.italic = YES;
        [string appendFormat:@"italic "];
        string.italic = NO;
    }];
    
    // Shadow
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(4.0f, 4.0f);
    shadow.shadowBlurRadius = 3.0f;
    string.shadow = shadow;
    [string appendFormat:@"\n\nShadow Text"];

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