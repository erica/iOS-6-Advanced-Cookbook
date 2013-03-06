/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import "ABContactsHelper.h"

#define ATTRIBUTES  @[@"number", @"gender", @"givenname", @"middleinitial", @"surname", @"streetaddress", @"city", @"state", @"zipcode", @"country", @"emailaddress", @"password", @"telephonenumber", @"mothersmaiden", @"birthday", @"cctype", @"ccnumber", @"cvv2", @"ccexpires", @"nationalid", @"ups", @"occupation", @"domain", @"bloodtype", @"pounds", @"kilograms", @"feetinches", @"centimeters"]


@interface FakePerson : NSObject
+ (ABContact *) randomPerson;
+ (NSDictionary *) fetchIdentity;
@end
