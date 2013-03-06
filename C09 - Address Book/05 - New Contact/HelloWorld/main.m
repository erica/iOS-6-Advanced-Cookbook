/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "FakePerson.h"
#import "Utility.h"
#import "ModalAlertDelegate.h"
#import "ABWrappers.h"

@interface TestBedViewController : UIViewController <ABNewPersonViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate>
@end

@implementation TestBedViewController
{
    UITextView *textView;
}

- (BOOL) ask: (NSString *) aQuestion
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:aQuestion message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:alertView];
    int response = [delegate show];
    return response;
}

#pragma mark NEW PERSON DELEGATE METHODS
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	if (person)
	{
		ABContact *contact = [ABContact contactWithRecord:person];
		self.title = [NSString stringWithFormat:@"Added %@", contact.compositeName];
        
        NSError *error;
		BOOL success = [ABContactsHelper addContact:contact withError:&error];
        if (!success)
        {
            NSLog(@"Could not add contact. %@", error.localizedFailureReason);
            self.title = @"Error.";
		}
        
        [ABStandin save:nil];
	}
	else
		self.title = @"Cancelled";
    
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PEOPLE PICKER DELEGATE METHODS
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	[self dismissViewControllerAnimated:YES completion:nil];

	ABContact *contact = [ABContact contactWithRecord:person];

    NSString *query = [NSString stringWithFormat:@"Really delete %@?",  contact.compositeName];
    if ([self ask:query])
	{
		self.title = [NSString stringWithFormat:@"Deleted %@", contact.compositeName];
		[contact removeSelfFromAddressBook:nil];
        [ABStandin save:nil];
	}
    
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	// required method that is never called in the people-only-picking
	[self dismissViewControllerAnimated:YES completion:nil];
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) add
{
	// create a new view controller
	ABNewPersonViewController *npvc = [[ABNewPersonViewController alloc] init];
	
	// Create a new contact
	ABContact *contact = [ABContact contact];
  	// ABContact *contact = [FakePerson randomPerson]; <-- use this for prepopluated
	npvc.displayedPerson = contact.record;
	
	// Set delegate
	npvc.newPersonViewDelegate = self;
	
	[self.navigationController pushViewController:npvc animated:YES];
}

- (void) remove
{
	ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
	ppnc.peoplePickerDelegate = self;
	[self presentViewController:ppnc animated:YES completion:nil];
}

- (void) enableGUI: (BOOL) yorn
{
    if (yorn)
    {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Add", @selector(add));
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Remove", @selector(remove));
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