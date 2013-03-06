/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.0 Edition
 BSD License, Use at your own risk
 */

#import "ABStandin.h"

static ABAddressBookRef shared = NULL;

@implementation ABStandin
// Return the current shared address book, 
// Creating if needed
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
    return shared;
}

// Load the current address book
+ (ABAddressBookRef) currentAddressBook
{
    if (shared)
    {
        CFRelease(shared);
        shared = nil;
    }
    
    return [self addressBook];
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

+ (void) load
{
    [ABStandin addressBook];
}
@end
