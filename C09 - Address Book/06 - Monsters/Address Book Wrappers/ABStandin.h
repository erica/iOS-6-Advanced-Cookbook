/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ABStandin : NSObject
+ (ABAddressBookRef) addressBook;
+ (ABAddressBookRef) currentAddressBook;
+ (BOOL) save: (NSError **) error;
+ (void) load;
@end
