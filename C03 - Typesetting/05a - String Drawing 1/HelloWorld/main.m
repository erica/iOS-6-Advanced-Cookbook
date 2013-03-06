/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "FancyString.h"
#import "Utility.h"

@interface ASView : UIView
@property (nonatomic, strong) NSAttributedString *attributedString;
@end

@implementation ASView
- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        self.backgroundColor = [UIColor clearColor];
    return self;
}

- (void) drawRect:(CGRect)rect
{
	[super drawRect: rect];
    [_attributedString drawInRect:self.bounds];
}
@end

@interface TestBedViewController : UIViewController
{
    ASView *asView;
    FancyString *string;
}
@end

@implementation TestBedViewController
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];

    string = [FancyString string];
    
    UIFont *headerFont = [UIFont fontWithName:@"Futura" size:36.0f];
    UIFont *baseFont = [UIFont fontWithName:@"Futura" size:18.0f];
    string.font = baseFont;
    
    string.paragraphStyle.firstLineHeadIndent = 10.0f;
    string.paragraphStyle.headIndent = 10.0f;
    string.paragraphStyle.tailIndent = -10.0f;
    [string setAlignment:@"justified"];
    [string setBreakMode:@"word"];
    
    [string performTransientAttributeBlock:^(){
        string.font = headerFont;
        string.bold = YES;
        string.foregroundColor = [UIColor redColor];
        [string appendFormat:@"Hello World!\n"];
    }];
    
    [string appendFormat:@"\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Donec et diam lacus. Mauris elit urna, cursus ut tristique eu, suscipit quis odio. Suspendisse ullamcorper dui ut elit blandit vulputate ornare nulla scelerisque. Proin molestie sollicitudin ultricies.\n\nSed lobortis, felis imperdiet tincidunt elementum, odio diam egestas massa, id tempor sem nisl id enim. Etiam pretium, eros vitae malesuada sagittis, metus nisi aliquam sem, id euismod neque arcu at erat. Aenean sit amet magna nec sapien sodales laoreet at sit amet dui."];    
    
    asView = [[ASView alloc] init];
    [self.view addSubview:asView];
    PREPCONSTRAINTS(asView);
    STRETCH_VIEW(self.view, asView);

    asView.attributedString = string.string;
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