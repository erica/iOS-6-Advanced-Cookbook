/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIImage-Rotation.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    CGFloat rot;
}

// Rotation test
- (void) test
{
    UIImage *sourceImage = [UIImage imageNamed:@"359.jpg"];
    if (rot > M_PI * 2.0f)
    {
        imageView.image = sourceImage;
        rot = 0.0f;
        return;
    }
    
    UIImage *image = rotatedImage(sourceImage, rot);
    imageView.image = image;
    
    rot += M_PI / 10.0f;
    [self performSelector:@selector(test) withObject:nil afterDelay:0.05f];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];    
    
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = [UIImage imageNamed:@"359.jpg"];
    [self.view addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    STRETCH_VIEW(self.view, imageView);
    
    self.navigationItem.rightBarButtonItems = @[
    BARBUTTON(@"Go", @selector(test)),
    ];
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