/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController <UIAccelerometerDelegate>
@end

@implementation TestBedViewController
{
    UIScrollView *sv;
    
    float xoff;
    float xaccel;
	float xvelocity;
    
    float yoff;
	float yaccel;
	float yvelocity;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// extract the acceleration components
	float xx = -acceleration.x;
	float yy = (acceleration.z + 0.5f) * 2.0f; // between face up and face forward
	
	// Has the direction changed?
	float accelDirX = SIGN(xvelocity) * -1.0f; 
	float newDirX = SIGN(xx);
	float accelDirY = SIGN(yvelocity) * -1.0f;
	float newDirY = SIGN(yy);
	
	// Accelerate. To increase viscosity lower the additive value
	if (accelDirX == newDirX) xaccel = (abs(xaccel) + 0.005f) * SIGN(xaccel);
	if (accelDirY == newDirY) yaccel = (abs(yaccel) + 0.005f) * SIGN(yaccel);
	
	// Apply acceleration changes to the current velocity
	xvelocity = -xaccel * xx;
	yvelocity = -yaccel * yy;
}

- (void) tick
{
    xoff += xvelocity;
    xoff = MIN(xoff, 1.0f);
    xoff = MAX(xoff, 0.0f);
    
    yoff += yvelocity;
    yoff = MIN(yoff, 1.0f);
    yoff = MAX(yoff, 0.0f);
    
    CGFloat xsize = sv.contentSize.width - sv.frame.size.width;
    CGFloat ysize = sv.contentSize.height - sv.frame.size.height;
    sv.contentOffset = CGPointMake(xoff * xsize, yoff * ysize);
}

- (void) loadView
{
    [super loadView];
    sv = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = sv;
}

- (void) viewDidAppear:(BOOL)animated
{
    NSString *map = @"http://maps.weather.com/images/maps/current/curwx_720x486.jpg";
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:
     ^{
         // Load the weather data
         NSURL *weatherURL = [NSURL URLWithString:map];
         NSData *imageData = [NSData dataWithContentsOfURL:weatherURL];
         
         // Update the image on the main thread using the main queue
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             UIImage *weatherImage = [UIImage imageWithData:imageData];
             UIImageView *imageView = [[UIImageView alloc] initWithImage:weatherImage];
             CGSize initSize = weatherImage.size;
             CGSize destSize = weatherImage.size;
             
             while ((destSize.width < (self.view.frame.size.width * 4)) ||
                    (destSize.height < (self.view.frame.size.height * 4)))
             {
                 destSize.width += initSize.width;
                 destSize.height += initSize.height;
             }
             
             imageView.userInteractionEnabled = NO;
             imageView.frame = (CGRect){.size = destSize};
             sv.contentSize = destSize;
             
             [sv addSubview:imageView];
             
             // Activate the accelerometer
             [[UIAccelerometer sharedAccelerometer] setDelegate:self];
             
             // Start the physics timer
             [NSTimer scheduledTimerWithTimeInterval: 0.03f target: self selector: @selector(tick) userInfo: nil repeats: YES];
         }];
     }];
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end
@implementation TestBedAppDelegate
{
	UIWindow *window;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
    [application setStatusBarHidden:YES];
    // [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    // UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = tbvc;
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