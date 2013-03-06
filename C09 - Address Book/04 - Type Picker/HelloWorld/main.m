/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "FakePerson.h"
#import "Utility.h"
#import "ABWrappers.h"

@interface TestBedViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate>
@end

@implementation TestBedViewController
{
    UITextView *textView;
}

#pragma mark PEOPLE PICKER DELEGATE METHODS
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    // Guaranteed to only be working with e-mail or phone here
    NSArray *array = [ABContact arrayForProperty:property inRecord:person];
    self.title = (NSString *)[array objectAtIndex:identifier];
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) email: (UIBarButtonItem *) bbi
{
    ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
    ppnc.peoplePickerDelegate = self;
    [ppnc setDisplayedProperties:[NSArray arrayWithObject:@(kABPersonEmailProperty)]];
    [self presentViewController:ppnc animated:YES completion:nil];
}

- (void) phone: (UIBarButtonItem *) bbi
{
    ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
    ppnc.peoplePickerDelegate = self;
    [ppnc setDisplayedProperties:[NSArray arrayWithObject:@(kABPersonPhoneProperty)]];
    [self presentViewController:ppnc animated:YES completion:nil];
}

- (void) enableGUI: (BOOL) yorn
{
    if (yorn)
    {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"E-mail", @selector(email:));
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Phone", @selector(phone:));
    }
    else
    {
        [ABStandin showDeniedAccessAlert];
    }
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    textView = [[UITextView alloc] init];
    textView.editable = NO;
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kAuthorizationUpdateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        NSNumber *granted = note.object;
        [self enableGUI:granted.boolValue];
    }];    
    [ABStandin requestAccess];
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
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srandom(time(0));
    
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	tbvc = [[TestBedViewController alloc] init];
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