/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.0 Edition
 BSD License, Use at your own risk
 */

#import "ABStandin.h"

static ABAddressBookRef shared = NULL;

@implementation ABStandin

// Update address book when changed
void addressBookUpdated(ABAddressBookRef reference, CFDictionaryRef dictionary, void *context)
{
    ABAddressBookRevert(reference);
}

// Return the current address book
+ (ABAddressBookRef) addressBook
{
    if (shared) return shared;
    
    CFErrorRef errorRef;
    shared = ABAddressBookCreateWithOptions(NULL, &errorRef);
    if (!shared)
    {
        NSError *error = (__bridge_transfer NSError *)errorRef;
        NSLog(@"Error creating new address book object: %@", error.localizedFailureReason);
        return nil;
    }

    ABAddressBookRegisterExternalChangeCallback(shared, addressBookUpdated, NULL);
    return shared;
}

// Load the current address book with updates
+ (ABAddressBookRef) currentAddressBook
{
    if (!shared)
        return [self addressBook];
    
    ABAddressBookRevert(shared);
    return shared;
}

// Thanks Frederic Bronner
// Save the address book out
+ (BOOL) save: (NSError **) error
{
    CFErrorRef errorRef;
    if (shared)
    {
        BOOL success = ABAddressBookSave(shared, &errorRef);
        if (!success)
        {
            if (error)
                *error = (__bridge_transfer NSError *)errorRef;
            return NO;
        }        
        return YES;
    }
    return NO;
}

// Test authorization status
+ (BOOL) authorized
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    return (status == kABAuthorizationStatusAuthorized);
}

// Fetch exact authorization status
+ (ABAuthorizationStatus) authorizationStatus
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    return status;
}

// Place access request
+ (void) requestAccess
{
    if ([self authorized])
    {
        NSNotification *note = [NSNotification notificationWithName:kAuthorizationUpdateNotification object:@YES];
        [[NSNotificationCenter defaultCenter] postNotification:note];
        return;
    }
    
    ABAddressBookRequestAccessCompletionHandler handler =
    ^(bool granted, CFErrorRef errorRef){
        if (errorRef)
        {
            NSError *error = (__bridge NSError *) errorRef;
            NSLog(@"Error requesting Address Book access: %@", error.localizedFailureReason);
            return;
        }

        // post notification on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotification *note = [NSNotification notificationWithName:kAuthorizationUpdateNotification object:@(granted)];
            [[NSNotificationCenter defaultCenter] postNotification:note];
        });
     };
    
    ABAddressBookRequestAccessWithCompletion(shared, handler);    
}

+ (void) showDeniedAccessAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Access Contacts" message:@"Please enable access in Settings > Privacy > Contacts." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}
@end
