/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Utility.h"

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate>
@end

@implementation TestBedViewController
{
    UITextView *textView;
    NSMutableString *log;
    CLLocationManager *manager;
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
    
    [log appendString:outstring];
    [log appendString:@"\n\n"];
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
    
    [self doLog:@"Location manager error: %@", error.localizedFailureReason];
    return;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
{
    CLLocation *newLocation = [locations lastObject];
    [self doLog:@"%@\n", [newLocation description]];
}

- (void) reverseGeocode: (id) sender
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:37.33168400 longitude:-122.03075800];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!placemarks)
         {
             [self doLog:@"Error retrieving placemarks: %@", error.localizedFailureReason];
             return;
         }
         
         [self doLog:@"Placemarks from Location: %f, %f", location.coordinate.latitude, location.coordinate.longitude];
         for (CLPlacemark *placemark in placemarks)
         {
             [self doLog:@"%@", placemark.description];
         }
     }];
    
}

- (void) geocode: (id) sender
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    NSString *address = @"1 Infinite Loop, Cupertino, CA 95014";
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!placemarks)
         {
             [self doLog:@"Error retrieving placemarks: %@", error.localizedFailureReason];
             return;
         }
         
         [self doLog:@"Placemarks from Description (%@):", address];
         for (CLPlacemark *placemark in placemarks)
         {
             [self doLog:@"%@", placemark.description];
         }
     }];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Reverse", @selector(reverseGeocode:));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Forward", @selector(geocode:));
    
    textView = [[UITextView alloc] init];
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Futura" size: IS_IPAD ? 24.0f : 12.0f];
    
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    log = [NSMutableString string];
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