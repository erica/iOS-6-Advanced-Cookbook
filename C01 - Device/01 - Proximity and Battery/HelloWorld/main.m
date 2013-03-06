/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UILabel *label;
}
- (void) peekAtBatteryState
{
    NSArray *stateArray = @[@"Battery state is unknown", @"Battery is not plugged into a charging source", @"Battery is charging", @"Battery state is full"];
    
    NSString *status = [NSString stringWithFormat:@"Battery state: %@, Battery level: %0.2f%%",
                        stateArray[[UIDevice currentDevice].batteryState],
                        [UIDevice currentDevice].batteryLevel * 100];
    
    NSLog(@"%@", status);
    label.text = status;
}

- (void) updateTitle
{
    self.title = [NSString stringWithFormat:@"Proximity %@", [UIDevice currentDevice].proximityMonitoringEnabled ? @"On" : @"Off"];
}

- (void) toggle: (id) sender
{
    // Determine the current proximity monitoring and toggle it
    BOOL isEnabled = [UIDevice currentDevice].proximityMonitoringEnabled;
    [UIDevice currentDevice].proximityMonitoringEnabled = !isEnabled;
    [self updateTitle];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 99;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:label];

    PREPCONSTRAINTS(label);
    CONSTRAIN(self.view, label, @"H:|-[label(>=0)]-|");
    CONSTRAIN(self.view, label, @"V:|[label(>=0)]|");
    
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Toggle", @selector(toggle:));
    [self updateTitle];
    
    // Add proximity state checker
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceProximityStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        NSLog(@"The proximity sensor %@", [UIDevice currentDevice].proximityState ?
              @"will now blank the screen" : @"will now restore the screen");
    }];
    
    // Enable battery monitoring
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    // Add observers for battery state and level changes
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceBatteryStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        NSLog(@"Battery State Change");
        [self peekAtBatteryState];
    }];
     
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceBatteryLevelDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        NSLog(@"Battery Level Change");
        [self peekAtBatteryState];
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