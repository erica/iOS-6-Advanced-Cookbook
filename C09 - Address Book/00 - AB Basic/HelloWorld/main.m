/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "FakePerson.h"
#import "Utility.h"
#import "ABWrappers.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UITextView *textView;
}
- (void) listContacts
{
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"Contacts:\n\n"];
    
    for (ABContact *contact in [ABContactsHelper contacts])
        [string appendFormat:@"%@ %@\n\t%@\n", contact.firstname, contact.lastname, contact.phonenumbers];
    
    textView.text = string;
}

- (void) addPerson
{
    ABContact *contact = [FakePerson randomPerson];
    [ABContactsHelper addContact:contact withError:nil];
    [ABStandin save:nil];
    [self listContacts];
}

- (ABContact *) buildSnigglebottom
{
    ABContact *contact = [ABContact contact];
    contact.firstname = @"Henry";
    contact.middlename = @"P";
    contact.lastname = @"Snigglebottom";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    NSString *birthday = @"05/01/1955";
    contact.birthday = [formatter dateFromString:birthday];
    
    NSError *error;
    BOOL success = [ABContactsHelper addContact:contact withError:&error];
    if (!success)
    {
        NSLog(@"Error adding contact : %@", error);
        return nil;
    }
    
    return contact;
}

- (void) relationTest
{
    ABContact *person = nil;
    NSArray *matches = [ABContactsHelper contactsMatchingName:@"Snigglebottom"];
    if (matches.count)
        person = matches[0];
    else
        return;
    
    // Add a fake person
    ABContact *contact = [FakePerson randomPerson];
    [ABContactsHelper addContact:contact withError:nil];
    [ABStandin save:nil];
    
    // Create friend relationship
    BOOL success = [person addRelationItem:contact.compositeName withLabel:kABPersonFriendLabel];
    if (success)
        [ABStandin save:nil];
    else
        NSLog(@"Error adding Friend");    
    NSLog(@"Added friend: %@", success ? @"Success" : @"Fail");
    
    // Add another person
    contact = [FakePerson randomPerson];
    [ABContactsHelper addContact:contact withError:nil];
    [ABStandin save:nil];
    
    // Create custom relationship
    NSString *relationType = @[@"Barber", @"Receptionist", @"Beautician", @"Accountant"][rand() % 4];
    success = [person addRelationItem:contact.compositeName withLabel:(__bridge CFStringRef)relationType];
    if (success)
        [ABStandin save:nil];
    else
        NSLog(@"Error adding custom relation");
    NSLog(@"Added %@: %@", relationType, success ? @"Success" : @"Fail");
   
}

// Keep randomly adding attributes to Henry Snigglebottom
- (void) sniggle
{
    ABContact *person = nil;
    NSArray *matches = [ABContactsHelper contactsMatchingName:@"Snigglebottom"];
    if (matches.count)
        person = matches[0];
    else
    {
        person = [self buildSnigglebottom];
        if (!person) return;
    }
    
    
    // About to add address, e-mail, phone number, website
    BOOL success;
    NSDictionary *identity = [FakePerson fetchIdentity];
    NSDictionary *address = [ABContact addressWithStreet:identity[@"streetaddress"]
                                                withCity:identity[@"city"]
                                               withState:identity[@"state"]
                                                 withZip:identity[@"zipcode"]
                                             withCountry:identity[@"country"]
                                                withCode:nil];
    success = [person addAddressItem:address withLabel:kABHomeLabel];
    NSLog(@"Added address: %@", success ? @"Success" : @"Fail");
    
    success = [person addEmailItem:identity[@"emailaddress"] withLabel:kABWorkLabel];
    NSLog(@"Added email: %@", success ? @"Success" : @"Fail");
    
    success = [person addPhoneItem:identity[@"telephonenumber"] withLabel:kABPersonPhoneMobileLabel];
    NSLog(@"Added phone: %@", success ? @"Success" : @"Fail");
    
    success = [person addURLItem:identity[@"domain"] withLabel:kABPersonHomePageLabel];
    NSLog(@"Added web: %@", success ? @"Success" : @"Fail");
    
    NSError *error;
    if (![ABStandin save:&error])
    {
        NSLog(@"Error saving address book: %@", error.localizedFailureReason);
        return;
    }
    
    [self relationTest];
    
    textView.text = [[person dictionaryRepresentation] description];
}

- (void) desniggle
{
    ABContact *person = nil;
    NSArray *matches = [ABContactsHelper contactsMatchingName:@"Snigglebottom"];
    if (matches.count)
        person = matches[0];
    else
        return;
    
    NSError *error;
    BOOL success = [person removeSelfFromAddressBook:&error];
    if (!success)
        NSLog(@"Error removing contact: %@", error.localizedFailureReason);
    else
        NSLog(@"Snigglebottom removed from contacts");
    
    if (![ABStandin save:&error])
    {
        NSLog(@"Error saving address book: %@", error.localizedFailureReason);
        return;
    }

    [self listContacts];
}

- (void) clean
{
    NSMutableArray *array = [NSMutableArray array];
    for (ABContact *contact in [ABContactsHelper contacts])
    {
        if (contact.note && [contact.note rangeOfString:@"FakePersonGeneration"].location != NSNotFound)
            [array addObject:contact];
        else if (contact.note)
            NSLog(@"Note did not match: %@", contact.note);
    }
    
    NSLog(@"Removing %d contacts", array.count);
    NSError *error;
    for (ABContact *contact in array)
    {
        NSLog(@"Removing: %@: %@", contact.compositeName, contact.note);
        if (![contact removeSelfFromAddressBook:&error])
            NSLog(@"Error removing contact: %@", error.localizedFailureReason);
    }
    
    if (![ABStandin save:&error])
    {
        NSLog(@"Error saving address book: %@", error.localizedFailureReason);
        return;
    }

    [self listContacts];
}

- (void) enableGUI: (BOOL) yorn
{
    if (yorn)
    {
        self.navigationItem.leftBarButtonItems = @[
        SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(addPerson)),
        SYSBARBUTTON(UIBarButtonSystemItemRefresh, @selector(listContacts)),
        SYSBARBUTTON(UIBarButtonSystemItemStop, @selector(clean)),
        BARBUTTON(@"Sniggle", @selector(sniggle)),
        BARBUTTON(@"Desniggle", @selector(desniggle)),
        ];
        
        [self listContacts];
    }
    else
    {
        self.navigationItem.leftBarButtonItems = nil;
        textView.text = @"User denied Address Book access. Update in Settings > Privacy > Contacts";
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