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
    NSMutableString *log;
    CLLocationManager *manager;
    CLLocation *mostRecentLocation;
    
    // Not for use in App Store apps
    NSObject *voiceSynthesizer;
    void *voiceServices;
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
    // [log appendString:outstring];
    // [log appendString:@"\n"];
    textView.text = log;
}

- (void) say: (NSString *) formatstring, ...
{
    if (!formatstring) return;
    
    va_list arglist;
    va_start(arglist, formatstring);
    NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
    va_end(arglist);
    
    // DO NOT USE THIS IN YOUR APPLICATIONS
    if (!voiceSynthesizer)
    {
        NSString *vsLocation = @"/System/Library/PrivateFrameworks/VoiceServices.framework/VoiceServices";
      	voiceServices = dlopen(vsLocation.UTF8String, RTLD_LAZY);
        voiceSynthesizer = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
    }
    [voiceSynthesizer performSelector:@selector(startSpeakingString:) withObject:outstring];
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

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)aRegion
{
    [self doLog:@"Entered region %@", aRegion.identifier];
    [self say:@"Entering %@", aRegion.identifier];
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)aRegion
{
    [self doLog:@"Leaving region %@", aRegion.identifier];
    [self say:@"Leaving %@", aRegion.identifier];
}

- (void)locationManager:(CLLocationManager *)aManager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    [self doLog:@"Location: %@\n", [newLocation description]];
    mostRecentLocation = newLocation;
}

- (void) startCL
{
    if (![CLLocationManager locationServicesEnabled])
    {
        [self doLog:@"User has disabled location services"];
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        [self doLog:@"User has denied location services"];
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [self doLog:@"About to prompt the user for permission"];
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        [self doLog:@"User has authorized location services"];
    }
        
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    manager.distanceFilter = 5.0f; // in meters
    [manager startUpdatingLocation];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self say:@"Voice Synthesizer is ready to go!"];
}

- (void) clearMonitoredRegions
{
    for (CLRegion *eachRegion in [manager monitoredRegions])
    {
        [self doLog:@"Stopping monitor for %@", eachRegion];
        [manager stopMonitoringForRegion:eachRegion];
    }
}

- (void) listMonitoredRegions
{
    for (CLRegion *eachRegion in [manager monitoredRegions])
        [self doLog:@"Region: %@", eachRegion];
}

- (void) markAndMonitor
{
    if (!mostRecentLocation)
    {
        [self doLog:@"No location. Sorry"];
        return;
    }
    
    [self doLog:@"Setting Geofence"];
    NSString *geofenceName = [NSString stringWithFormat:@"Region #%d", manager.monitoredRegions.count + 1];
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:mostRecentLocation.coordinate radius:50.0f identifier:geofenceName];
    [manager startMonitoringForRegion:region];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];

    if ([CLLocationManager regionMonitoringAvailable])
    {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Mark", @selector(markAndMonitor));
        self.navigationItem.leftBarButtonItems =
        @[
        BARBUTTON(@"Clear", @selector(clearMonitoredRegions)),
        BARBUTTON(@"List", @selector(listMonitoredRegions)),
        ];
    }
    
    textView = [[UITextView alloc] init];
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Futura" size: IS_IPAD ? 24.0f : 12.0f];
    
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);

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