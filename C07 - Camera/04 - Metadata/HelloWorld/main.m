/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import "MetaImage.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

// Return a swatch with the given color
- (UIImage *) swatchWithColor:(UIColor *) color andSize: (CGFloat) side
{
    UIGraphicsBeginImageContext(CGSizeMake(side, side));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, side, side));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) action
{
    NSString *destPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.jpg"];
    UIImage *image = [self swatchWithColor:COOKBOOK_PURPLE_COLOR andSize:200.0f];
    
    // Create a new image and write it out
    MetaImage *mi = [MetaImage newImage:image];
    mi.exif[@"UserComment"] = @"This is a test comment";
    [mi writeToPath:destPath];
    
    // Read it back in
    mi = [MetaImage imageFromPath:destPath];
    NSLog(@"%@", mi.properties);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(action));
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