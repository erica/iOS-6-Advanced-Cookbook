/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-Transform.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIView *testView;
    UIImageView *topRightView;
    CGFloat theta;
    NSTimer *timer;
    
    // Scaling just one dimension causes rotation distortion
    BOOL xBig;
    BOOL yBig;
    BOOL translated;
}


#pragma mark - Rotation 

- (void) performRotate
{
    // NSLog(@"%@", testView.transformDescription);

    theta += M_PI / 60.0f;
    testView.rotation = theta;
    topRightView.center = testView.transformedTopRight;
}

- (void) toggleRotation
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    else
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(performRotate) userInfo:nil repeats:YES];
    }
}

#pragma mark - Scaling and Translation

- (void) toggleX
{
    xBig = !xBig;
    testView.xscale = xBig ? 1.5f : 1.0f;
    topRightView.center = testView.transformedTopRight;
}

- (void) toggleY
{
    yBig = !yBig;
    testView.yscale = yBig ? 1.5f : 1.0f;
    topRightView.center = testView.transformedTopRight;
}

- (void) toggleTranslated
{
    translated = !translated;
    testView.tx = translated ? 20.0f : 0.0f;
    testView.ty = translated ? 20.0f : 0.0f;
    topRightView.center = testView.transformedTopRight;
}

- (void) viewWillAppear:(BOOL)animated
{
    testView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    
    topRightView.center = testView.transformedTopRight;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    testView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 150.0f)];
    testView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:testView];
    
    topRightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle.png"]];
    [self.view addSubview:topRightView];
    
    self.navigationItem.leftBarButtonItems = @[
        BARBUTTON(@"X", @selector(toggleX)),
        BARBUTTON(@"Y", @selector(toggleY)),
        BARBUTTON(@"T", @selector(toggleTranslated)),
    ];
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(toggleRotation));
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