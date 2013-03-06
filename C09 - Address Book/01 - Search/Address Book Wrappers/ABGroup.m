/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.0 Edition
 BSD License, Use at your own risk
 */

#import "ABGroup.h"
#import "ABContactsHelper.h"
#import "ABStandin.h"

@implementation ABGroup

// Thanks to Quentarez, Ciaran
- (id) initWithRecord: (ABRecordRef) aRecord
{
    if (self = [super init]) _record = CFRetain(aRecord);
    return self;
}

- (void) dealloc
{
    if (_record) 
        CFRelease(_record);
}

+ (id) groupWithRecord: (ABRecordRef) grouprec
{
    return [[ABGroup alloc] initWithRecord:grouprec];
}

+ (id) groupWithRecordID: (ABRecordID) recordID
{
    ABAddressBookRef addressBook = [ABStandin addressBook];
    ABRecordRef grouprec = ABAddressBookGetGroupWithRecordID(addressBook, recordID);
    ABGroup *group = [self groupWithRecord:grouprec];
    return group;
}

// Thanks to Ciaran
+ (id) group
{
    ABRecordRef grouprec = ABGroupCreate();
    id group = [ABGroup groupWithRecord:grouprec];
    CFRelease(grouprec);
    return group;
}


// Thanks to Eridius for suggestions re: error
// Thanks Rincewind42 for the *error transfer bridging
- (BOOL) removeSelfFromAddressBook: (NSError **) error
{
    CFErrorRef errorRef = NULL;
    BOOL success;
    
    ABAddressBookRef addressBook = [ABStandin addressBook];
    
    success = ABAddressBookRemoveRecord(addressBook, self.record, &errorRef);
    if (!success)
    {
        if (error)
            *error = (__bridge_transfer NSError *)errorRef;
        return NO;
    }

    return success;
}

#pragma mark Record ID and Type
- (ABRecordID) recordID {return ABRecordGetRecordID(_record);}
- (ABRecordType) recordType {return ABRecordGetRecordType(_record);}
- (BOOL) isPerson {return self.recordType == kABPersonType;}

#pragma mark management
- (NSArray *) members
{
    NSArray *contacts = (__bridge_transfer NSArray *)ABGroupCopyArrayOfAllMembers(self.record);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:contacts.count];
    for (id contact in contacts)
        [array addObject:[ABContact contactWithRecord:(__bridge ABRecordRef)contact]];
    return array;
}

// kABPersonSortByFirstName = 0, kABPersonSortByLastName  = 1
- (NSArray *) membersWithSorting: (ABPersonSortOrdering) ordering
{
    NSArray *contacts = (__bridge_transfer NSArray *)ABGroupCopyArrayOfAllMembersWithSortOrdering(self.record, ordering);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:contacts.count];
    for (id contact in contacts)
        [array addObject:[ABContact contactWithRecord:(__bridge ABRecordRef)contact]];
    return array;
}

- (BOOL) addMember: (ABContact *) contact withError: (NSError **) error
{
    CFErrorRef errorRef = NULL;
    BOOL success;
    
    success = ABGroupAddMember(self.record, contact.record, &errorRef);
    if (!success)
    {
        if (error)
            *error = (__bridge_transfer NSError *)errorRef;
        return NO;
    }
    
    return YES;
}

- (BOOL) removeMember: (ABContact *) contact withError: (NSError **) error
{
    CFErrorRef errorRef = NULL;
    BOOL success;
    
    success = ABGroupRemoveMember(self.record, contact.record, &errorRef);
    if (!success)
    {
        if (error)
            *error = (__bridge_transfer NSError *)errorRef;
        return NO;
    }
    
    return YES;
}

#pragma mark name

- (NSString *) getRecordString:(ABPropertyID) anID
{
    return (__bridge_transfer NSString *) ABRecordCopyValue(_record, anID);
}

- (NSString *) name
{
    return [self getRecordString:kABGroupNameProperty];
}

- (void) setName: (NSString *) aString
{
    CFErrorRef errorRef = NULL;
    BOOL success;
    
    success = ABRecordSetValue(_record, kABGroupNameProperty, (__bridge CFStringRef) aString, &errorRef);
    if (!success)
    {
        NSError *error = (__bridge_transfer NSError *) errorRef;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
}
@end
