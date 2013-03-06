/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#define kAuthorizationUpdateNotification @"ABAuthorizationNotification"

@interface ABStandin : NSObject
+ (ABAddressBookRef) addressBook;
+ (ABAddressBookRef) currentAddressBook;
+ (BOOL) save: (NSError **) error;
+ (BOOL) authorized;
+ (ABAuthorizationStatus) authorizationStatus;
+ (void) requestAccess;
+ (void) showDeniedAccessAlert;
@end
