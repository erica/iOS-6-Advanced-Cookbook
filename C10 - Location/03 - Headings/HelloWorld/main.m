/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <dlfcn.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate>
@end

@implementation TestBedViewController
{
    UITextView *textView;
    UIImageView *imageView;
    NSMutableString *log;
    CLLocationManager *manager;
    CLLocation *mostRecentLocation;
}

// Utility
- (void) doLog: (NSString *) formatstring, ...
{
    if (!formatstring) return;
    
    va_list arglist;
    va_start(arglist, formatstring);
    NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
    va_end(arglist);
    
    if (!log) log = [NSMutableString string];
    NSLog(@"%@", outstring);
    
    [log insertString:@"\n" atIndex:0];
    [log insertString:outstring atIndex:0];
    textView.text = log;
}

#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([CLLocationManager authorizationStatus] ==
        kCLAuthorizationStatusDenied)
    {
        [self doLog:@"User has denied location services"];
        return;
    }
    
    [self doLog:@"Location manager error: %@", error.localizedDescription];
    return;
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    CGFloat heading = -M_PI * newHeading.magneticHeading / 180.0f;
    imageView.transform = CGAffineTransformMakeRotation(heading);
}

- (void) startCL
{
    if (![CLLocationManager locationServicesEnabled])
    {
        [self doLog:@"User has disabled location services"];
        return;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        [self doLog:@"User has denied location services"];
        return;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [self doLog:@"Auth status not determined"];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        [self doLog:@"User has authorized location services"];
    }
        
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    manager.distanceFilter = 5.0f; // in meters
   
    if ([CLLocationManager headingAvailable])
        [manager startUpdatingHeading];
    else
        imageView.alpha = 0.0f;

}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];

    textView = [[UITextView alloc] init];
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Futura" size: IS_IPAD ? 24.0f : 12.0f];
    
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);

    UIImage *image = [UIImage imageNamed:@"arrow.png"];
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:imageView];
    imageView.frame = (CGRect){.size = image.size};
    imageView.center = RECTCENTER([[UIScreen mainScreen] bounds]);

    log = [NSMutableString string];
    [self startCL];
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