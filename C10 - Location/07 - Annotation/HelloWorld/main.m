/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
@end

@implementation TestBedViewController
{
    MKMapView *mapView;
	CLLocation *current;
}

// Update current location when the user interacts with map
- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
    current = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
}

- (void)mapView:(MKMapView *)aMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D viewCoord = view.annotation.coordinate;
    CLLocation *annotationLocation = [[CLLocation alloc] initWithLatitude:viewCoord.latitude longitude:viewCoord.longitude];
    CLLocation *userLocation = mapView.userLocation.location;
    
    float distance = [userLocation distanceFromLocation:annotationLocation];
    self.title = [NSString stringWithFormat:@"%0.0f meters", distance];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	// Initialize each view
	for (MKPinAnnotationView *mkaview in views)
	{
        if (![mkaview isKindOfClass:[MKPinAnnotationView class]])
            continue;
        
        // Set the color to purple
        mkaview.pinColor = MKPinAnnotationColorPurple;
        
		// Add buttons to each one
		UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		mkaview.rightCalloutAccessoryView = button;
	}
}

- (void) tag
{
    MapAnnotation *annotation = [[MapAnnotation alloc] initWithCoordinate:current.coordinate];
    
    NSString *locString = [NSString stringWithFormat:@"%f, %f", current.coordinate.latitude, current.coordinate.longitude];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeStyle = NSDateFormatterLongStyle;
    annotation.title = [formatter stringFromDate:[NSDate date]];
    annotation.subtitle = locString;
    
    [mapView addAnnotation:annotation];
}

- (void) clear
{
    NSArray *annotations = [NSArray arrayWithArray:mapView.annotations];
    for (id annotation in annotations)
        if (![annotation isKindOfClass:[MKUserLocation class]])
            [mapView removeAnnotation:annotation];
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
    
	if (!CLLocationManager.locationServicesEnabled)
	{
		NSLog(@"User has opted out of location services");
		return;
	}
	else
    {
		mapView.delegate = self;
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Tag", @selector(tag));
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Clear", @selector(clear));
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