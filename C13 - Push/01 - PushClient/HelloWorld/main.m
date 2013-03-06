/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"


@interface TestBedViewController : UIViewController
@property (nonatomic, readonly) UITextView *textView;
@end

@implementation TestBedViewController
{
    UISwitch *badgeSwitch;
    UISwitch *alertSwitch;
    UISwitch *soundSwitch;
}

// Basic status
NSString *pushStatus ()
{
    return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] ?
    @"Notifications were active for this application" :
    @"Remote notifications were not active for this application";
}

// Fetch the current switch settings
- (NSUInteger) switchSettings
{
    NSUInteger settings = 0;
    if (badgeSwitch.isOn) settings = settings | UIRemoteNotificationTypeBadge;
    if (alertSwitch.isOn) settings = settings | UIRemoteNotificationTypeAlert;
    if (soundSwitch.isOn) settings = settings | UIRemoteNotificationTypeSound;
    return settings;
}

// Change the switches to match reality
- (void) updateSwitches
{
    NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    badgeSwitch.on = (rntypes & UIRemoteNotificationTypeBadge);
    alertSwitch.on = (rntypes & UIRemoteNotificationTypeAlert);
    soundSwitch.on = (rntypes & UIRemoteNotificationTypeSound);
}

// Register application for the services set out by the switches
- (void) registerServices
{
    if (![self switchSettings])
    {
        _textView.text = [NSString stringWithFormat:@"%@\nNothing to register. Skipping.\n(Did you mean to press Unregister instead?)", pushStatus()];
        [self updateSwitches];
        return;
    }
    
    NSString *status = [NSString stringWithFormat:@"%@\nAttempting registration", pushStatus()];
    _textView.text = status;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:[self switchSettings]];
}

// Unregister application for all push notifications
- (void) unregisterServices
{
    NSString *status = [NSString stringWithFormat:@"%@\nUnregistering.", pushStatus()];
    _textView.text = status;
    
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [self updateSwitches];
}

- (UILabel *) label: (NSString *) labelString
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 40.0f)];
    label.textAlignment = NSTextAlignmentRight;
    label.font = [UIFont fontWithName:@"Futura" size: 24.0f];
    label.text = labelString;
    label.textColor = COOKBOOK_PURPLE_COLOR;
    [self.view addSubview:label];
    PREPCONSTRAINTS(label);
    return label;
}

- (UISwitch *) newSwitch
{
    UISwitch *theSwitch = [[UISwitch alloc] init];
    [self.view addSubview:theSwitch];
    PREPCONSTRAINTS(theSwitch);
    return theSwitch;
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];   
        
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Register", @selector(registerServices));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Unregister", @selector(unregisterServices));
    
    _textView = [[UITextView alloc] init];
    _textView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.75f];
    _textView.editable = NO;
    _textView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 28.0f : 14.0f];
    _textView.textColor = COOKBOOK_PURPLE_COLOR;
    [self.view addSubview:_textView];
    
    PREPCONSTRAINTS(_textView);
    CONSTRAIN(self.view, _textView, @"V:|-[_textView(>=0)]-100-|");
    CONSTRAIN(self.view, _textView, @"H:|-[_textView(>=0)]-|");
    
    NSArray *labelText = [@"Badge*Alert*Sound" componentsSeparatedByString:@"*"];
    
    UILabel *label = [self label:labelText[0]];
    badgeSwitch = [self newSwitch];
    CONSTRAIN(self.view, label, @"H:|-[label]");
    CONSTRAIN(self.view, badgeSwitch, @"H:|-[badgeSwitch]");    
    CONSTRAIN(self.view, label, @"V:[label]-50-|");
    CONSTRAIN(self.view, badgeSwitch, @"V:[badgeSwitch]-|");

    label = [self label:labelText[1]];
    alertSwitch = [self newSwitch];
    CENTER_VIEW_H(self.view, label);
    CENTER_VIEW_H(self.view, alertSwitch);
    CONSTRAIN(self.view, label, @"V:[label]-50-|");
    CONSTRAIN(self.view, alertSwitch, @"V:[alertSwitch]-|");
    
    label = [self label:labelText[2]];
    soundSwitch = [self newSwitch];
    CONSTRAIN(self.view, label, @"H:[label]-|");
    CONSTRAIN(self.view, soundSwitch, @"H:[soundSwitch]-|");
    CONSTRAIN(self.view, label, @"V:[label]-50-|");
    CONSTRAIN(self.view, soundSwitch, @"V:[soundSwitch]-|");
    
    TestBedViewController __weak *weakself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         [[UIApplication sharedApplication] registerForRemoteNotificationTypes:[weakself switchSettings]];
         [weakself updateSwitches];
     }];
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    TestBedViewController *tbvc;
}
@end
@implementation TestBedAppDelegate

// Retrieve the device token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    NSString *results = [NSString stringWithFormat:@"Badge: %@, Alert:%@, Sound: %@",
                         (rntypes & UIRemoteNotificationTypeBadge) ? @"Yes" : @"No",
                         (rntypes & UIRemoteNotificationTypeAlert) ? @"Yes" : @"No",
                         (rntypes & UIRemoteNotificationTypeSound) ? @"Yes" : @"No"];
    
    NSLog(@"Enabled notification types: %d", rntypes);
    
    NSString *status = [NSString stringWithFormat:@"%@\nRegistration succeeded.\n\nDevice Token: %@\n%@", pushStatus(), deviceToken, results];
    tbvc.textView.text = status;
    NSLog(@"deviceToken: %@", deviceToken);
    [deviceToken.description writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DeviceToken.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error registering for remote notifications: %@", error.localizedFailureReason);
    NSString *status = [NSString stringWithFormat:@"%@\nRegistration failed.\n\nError: %@", pushStatus(), error.localizedFailureReason];
    tbvc.textView.text = status;
}

// Handle an actual notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *status = [NSString stringWithFormat:@"Notification received:\n%@", userInfo.description];
    tbvc.textView.text = status;
    NSLog(@"%@", userInfo);
}

- (void) showString: (NSString *) aString
{
    tbvc.textView.text = aString;
}

// Report the notification payload when launched by alert
- (void) launchNotification: (NSNotification *) notification
{
    // This is a workaround to allow the text view to be created if needed first
    [self performSelector:@selector(showString:) withObject:[[notification userInfo] description] afterDelay:1.0f];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
    [window makeKeyAndVisible];
    
    // Listen for remote notification launches
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchNotification:) name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
    
    NSLog(@"Launch options: %@", launchOptions);

    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}