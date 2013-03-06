/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

#import "Utility.h"

#define MAX_TIME	10

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate>
@end

@implementation TestBedViewController
{
    MKMapView *mapView;
    UITextView *textView;
    BOOL active;
}

#pragma mark -

// Search for n seconds to get the best location during that time
- (void) tick: (NSTimer *) timer
{
    self.title = @"Searching...";
	if (mapView.userLocation)
    {
        // Check for valid coordinate
        CLLocationCoordinate2D coord = mapView.userLocation.location.coordinate;
        if (!coord.latitude && !coord.longitude)
        {
            NSLog(@"Invalid location");
            return;
        }
        
        // Update titles
        self.title = @"Found!";
		[mapView setRegion:MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.005f, 0.005f)) animated:NO];
        mapView.userLocation.title = @"Location Coordinates";
        mapView.userLocation.subtitle = [NSString stringWithFormat:@"%f, %f", coord.latitude, coord.longitude];
        
        // Attempt to retrieve placemarks
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (!placemarks)
             {
                 NSLog(@"Error retrieving placemarks: %@", error.localizedFailureReason);
                 return;
             }
             
             NSMutableString *marks = [NSMutableString string];
             for (CLPlacemark *placemark in placemarks)
             {
                 [marks appendFormat:@"\n%@", placemark.description];
                 textView.alpha = 0.75f;
                 textView.text = marks;
             }
         }];
    }
    else
        self.title = @"???";
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    mapView = [[MKMapView alloc] init];
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    [self.view addSubview:mapView];
    PREPCONSTRAINTS(mapView);
    STRETCH_VIEW(self.view, mapView);
    
    textView = [[UITextView alloc] init];
    textView.editable = NO;
    
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW_H(self.view, textView);
    ALIGN_VIEW_BOTTOM(self.view, textView);
    [self.view  addConstraint:[NSLayoutConstraint constraintWithItem:textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.3f constant:0.0f]];
    textView.alpha = 0.0f;
    
	if (![CLLocationManager locationServicesEnabled])
	{
		NSLog(@"User has opted out of location services");
		return;
	}
	else
	{
        [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(tick:) userInfo:nil repeats:YES];
	}
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