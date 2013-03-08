/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.0 Edition
 BSD License, Use at your own risk
 */

#import "ABContact.h"
#import "ABContactsHelper.h"
#import "ABStandin.h"

@implementation ABContact
#pragma mark - Contacts

// Thanks to Quentarez, Ciaran
- (id) initWithRecord: (ABRecordRef) aRecord
{
    if (self = [super init]) 
        _record = CFRetain(aRecord);
    return self;
}

+ (id) contactWithRecord: (ABRecordRef) person
{
    return [[ABContact alloc] initWithRecord:person];
}

+ (id) contactWithRecordID: (ABRecordID) recordID
{
    ABAddressBookRef addressBook = [ABStandin addressBook];
    ABRecordRef contactrec = ABAddressBookGetPersonWithRecordID(addressBook, recordID);
    if (!contactrec) return nil; // Thanks, Frederic Bronner

    ABContact *contact = [self contactWithRecord:contactrec];
    return contact;
}

// Thanks to Ciaran
+ (id) contact
{
    ABRecordRef person = ABPersonCreate();
    id contact = [ABContact contactWithRecord:person];
    CFRelease(person);
    return contact;
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

- (void) dealloc
{
    if (_record) 
        CFRelease(_record);
}

#pragma mark Sorting

- (BOOL) isEqualToString: (ABContact *) aContact
{
    return [self.compositeName isEqualToString:aContact.compositeName];
}

- (NSComparisonResult) caseInsensitiveCompare: (ABContact *) aContact
{
    return [self.compositeName caseInsensitiveCompare:aContact.compositeName];
}

#pragma mark Utilities
+ (NSString *) localizedPropertyName: (ABPropertyID) aProperty
{
    return (__bridge_transfer NSString *)ABPersonCopyLocalizedPropertyName(aProperty);
}

+ (ABPropertyType) propertyType: (ABPropertyID) aProperty
{
    return ABPersonGetTypeOfProperty(aProperty);
}

// Thanks to Eridius for switchification
+ (NSString *) propertyTypeString: (ABPropertyID) aProperty
{
    switch (ABPersonGetTypeOfProperty(aProperty))
    {
        case kABInvalidPropertyType: return @"Invalid Property";
        case kABStringPropertyType: return @"String";
        case kABIntegerPropertyType: return @"Integer";
        case kABRealPropertyType: return @"Float";
        case kABDateTimePropertyType: return DATE_STRING;
        case kABDictionaryPropertyType: return @"Dictionary";
        case kABMultiStringPropertyType: return @"Multi String";
        case kABMultiIntegerPropertyType: return @"Multi Integer";
        case kABMultiRealPropertyType: return @"Multi Float";
        case kABMultiDateTimePropertyType: return @"Multi Date";
        case kABMultiDictionaryPropertyType: return @"Multi Dictionary";
        default: return @"Invalid Property";
    }
}

+ (NSString *) propertyString: (ABPropertyID) aProperty
{
    if (aProperty == kABPersonFirstNameProperty) return FIRST_NAME_STRING;
    if (aProperty == kABPersonMiddleNameProperty) return MIDDLE_NAME_STRING;
    if (aProperty == kABPersonLastNameProperty) return LAST_NAME_STRING;

    if (aProperty == kABPersonPrefixProperty) return PREFIX_STRING;
    if (aProperty == kABPersonSuffixProperty) return SUFFIX_STRING;
    if (aProperty == kABPersonNicknameProperty) return NICKNAME_STRING;

    if (aProperty == kABPersonFirstNamePhoneticProperty) return PHONETIC_FIRST_STRING;
    if (aProperty == kABPersonMiddleNamePhoneticProperty) return PHONETIC_MIDDLE_STRING;
    if (aProperty == kABPersonLastNamePhoneticProperty) return PHONETIC_LAST_STRING;

    if (aProperty == kABPersonOrganizationProperty) return ORGANIZATION_STRING;
    if (aProperty == kABPersonJobTitleProperty) return JOBTITLE_STRING;
    if (aProperty == kABPersonDepartmentProperty) return DEPARTMENT_STRING;
    
    if (aProperty == kABPersonNoteProperty) return NOTE_STRING;

    if (aProperty == kABPersonKindProperty) return KIND_STRING;

    if (aProperty == kABPersonBirthdayProperty) return BIRTHDAY_STRING;
    if (aProperty == kABPersonCreationDateProperty) return CREATION_DATE_STRING;
    if (aProperty == kABPersonModificationDateProperty) return MODIFICATION_DATE_STRING;

    if (aProperty == kABPersonEmailProperty) return EMAIL_STRING;
    if (aProperty == kABPersonAddressProperty) return ADDRESS_STRING;
    if (aProperty == kABPersonDateProperty) return DATE_STRING;
    if (aProperty == kABPersonPhoneProperty) return PHONE_STRING;
    if (aProperty == kABPersonInstantMessageProperty) return IM_STRING;
    if (aProperty == kABPersonURLProperty) return URL_STRING;
    if (aProperty == kABPersonSocialProfileProperty) return SOCIAL_STRING;
    if (aProperty == kABPersonRelatedNamesProperty) return RELATED_STRING;

    return nil;
}

+ (NSArray *) arrayForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record
{
    // Recover the property for a given record
    CFTypeRef theProperty = ABRecordCopyValue(record, anID);
    NSArray *items = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
    CFRelease(theProperty);
    return items;
}

+ (id) objectForProperty: (ABPropertyID) anID inRecord: (ABRecordRef) record
{
    return (__bridge_transfer id) ABRecordCopyValue(record, anID);
}

#pragma mark Record ID and Type

- (ABRecordID) recordID {return ABRecordGetRecordID(_record);}
- (ABRecordType) recordType {return ABRecordGetRecordType(_record);}
- (BOOL) isPerson {return self.recordType == kABPersonType;}

#pragma mark String Retrieval

- (NSString *) getRecordString:(ABPropertyID) anID
{
    NSString *result = (__bridge_transfer NSString *) ABRecordCopyValue(_record, anID);
    return result;
}
- (NSString *) firstname {return [self getRecordString:kABPersonFirstNameProperty];}
- (NSString *) middlename {return [self getRecordString:kABPersonMiddleNameProperty];}
- (NSString *) lastname {return [self getRecordString:kABPersonLastNameProperty];}

- (NSString *) prefix {return [self getRecordString:kABPersonPrefixProperty];}
- (NSString *) suffix {return [self getRecordString:kABPersonSuffixProperty];}
- (NSString *) nickname {return [self getRecordString:kABPersonNicknameProperty];}

- (NSString *) firstnamephonetic {return [self getRecordString:kABPersonFirstNamePhoneticProperty];}
- (NSString *) middlenamephonetic {return [self getRecordString:kABPersonMiddleNamePhoneticProperty];}
- (NSString *) lastnamephonetic {return [self getRecordString:kABPersonLastNamePhoneticProperty];}

- (NSString *) organization {return [self getRecordString:kABPersonOrganizationProperty];}
- (NSString *) jobtitle {return [self getRecordString:kABPersonJobTitleProperty];}
- (NSString *) department {return [self getRecordString:kABPersonDepartmentProperty];}
- (NSString *) note {return [self getRecordString:kABPersonNoteProperty];}


#pragma mark Setting Strings
- (BOOL) setString: (NSString *) aString forProperty:(ABPropertyID) anID
{
    CFErrorRef errorRef = NULL;
    BOOL success = ABRecordSetValue(_record, anID, (__bridge CFStringRef) aString, &errorRef);
    if (!success) 
    {
        NSError *error = (__bridge_transfer NSError *) errorRef;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return success;
}

- (void) setFirstname: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNameProperty];}
- (void) setMiddlename: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNameProperty];}
- (void) setLastname: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNameProperty];}

- (void) setPrefix: (NSString *) aString {[self setString: aString forProperty: kABPersonPrefixProperty];}
- (void) setSuffix: (NSString *) aString {[self setString: aString forProperty: kABPersonSuffixProperty];}
- (void) setNickname: (NSString *) aString {[self setString: aString forProperty: kABPersonNicknameProperty];}

- (void) setFirstnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNamePhoneticProperty];}
- (void) setMiddlenamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNamePhoneticProperty];}
- (void) setLastnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNamePhoneticProperty];}

- (void) setOrganization: (NSString *) aString {[self setString: aString forProperty: kABPersonOrganizationProperty];}
- (void) setJobtitle: (NSString *) aString {[self setString: aString forProperty: kABPersonJobTitleProperty];}
- (void) setDepartment: (NSString *) aString {[self setString: aString forProperty: kABPersonDepartmentProperty];}

- (void) setNote: (NSString *) aString {[self setString: aString forProperty: kABPersonNoteProperty];}

#pragma mark Contact Name
- (NSString *) contactName
{
    NSMutableString *string = [NSMutableString string];
    
    if (self.firstname || self.lastname)
    {
        if (self.prefix) [string appendFormat:@"%@ ", self.prefix];
        if (self.firstname) [string appendFormat:@"%@ ", self.firstname];
        if (self.nickname) [string appendFormat:@"\"%@\" ", self.nickname];
        if (self.lastname) [string appendFormat:@"%@", self.lastname];
        
        if (self.suffix && string.length)
            [string appendFormat:@", %@ ", self.suffix];
        else
            [string appendFormat:@" "];
    }
    
    if (self.organization) [string appendString:self.organization];
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) compositeName
{
    return (__bridge_transfer NSString *)ABRecordCopyCompositeName(_record);
}

#pragma mark Numbers

- (NSNumber *) getRecordNumber: (ABPropertyID) anID
{
    return (__bridge_transfer NSNumber *) ABRecordCopyValue(_record, anID);
}

- (NSNumber *) kind {return [self getRecordNumber:kABPersonKindProperty];}


#pragma mark Setting Numbers
- (BOOL) setNumber: (NSNumber *) aNumber forProperty:(ABPropertyID) anID
{
    CFErrorRef errorRef = NULL;
    BOOL success = ABRecordSetValue(_record, anID, (__bridge CFNumberRef) aNumber, &errorRef);
    if (!success) 
    {
        NSError *error = (__bridge_transfer NSError *) errorRef;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return success;
}

// const CFNumberRef kABPersonKindPerson;
// const CFNumberRef kABPersonKindOrganization;
- (void) setKind: (NSNumber *) aKind {[self setNumber:aKind forProperty: kABPersonKindProperty];}

#pragma mark Dates

- (NSDate *) getRecordDate:(ABPropertyID) anID
{
    return (__bridge_transfer NSDate *) ABRecordCopyValue(_record, anID);
}

- (NSDate *) birthday {return [self getRecordDate:kABPersonBirthdayProperty];}
- (NSDate *) creationDate {return [self getRecordDate:kABPersonCreationDateProperty];}
- (NSDate *) modificationDate {return [self getRecordDate:kABPersonModificationDateProperty];}

#pragma mark Setting Dates

- (BOOL) setDate: (NSDate *) aDate forProperty:(ABPropertyID) anID
{
    CFErrorRef errorRef = NULL;
    BOOL success = ABRecordSetValue(_record, anID, (__bridge CFDateRef) aDate, &errorRef);
    if (!success) 
    {
        NSError *error = (__bridge_transfer NSError *) errorRef;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return success;
}

- (void) setBirthday: (NSDate *) aDate {[self setDate: aDate forProperty: kABPersonBirthdayProperty];}


#pragma mark Images

- (UIImage *) image
{
    if (!ABPersonHasImageData(_record)) return nil;
    CFDataRef imageData = ABPersonCopyImageData(_record);
    if (!imageData) return nil;
    
    NSData *data = (__bridge_transfer NSData *)imageData;
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

- (void) setImage: (UIImage *) image
{
    CFErrorRef errorRef = NULL;
    BOOL success;
    
    if (image == nil) // remove
    {
        if (!ABPersonHasImageData(_record)) return; // no image to remove
        success = ABPersonRemoveImageData(_record, &errorRef);
        if (!success) 
        {
            NSError *error = (__bridge_transfer NSError *) errorRef;
            NSLog(@"Error: %@", error.localizedFailureReason);
        }
        return;
    }
    
    NSData *data = UIImagePNGRepresentation(image);
    success = ABPersonSetImageData(_record, (__bridge CFDataRef) data, &errorRef);
    if (!success) 
    {
        NSError *error = (__bridge_transfer NSError *) errorRef;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return;
}

#pragma mark MultiValue
+ (BOOL) propertyIsMultiValue: (ABPropertyID) aProperty;
{
    if (aProperty == kABPersonFirstNameProperty) return NO;
    if (aProperty == kABPersonMiddleNameProperty) return NO;
    if (aProperty == kABPersonLastNameProperty) return NO;
    
    if (aProperty == kABPersonPrefixProperty) return NO;
    if (aProperty == kABPersonSuffixProperty) return NO;
    if (aProperty == kABPersonNicknameProperty) return NO;
    
    if (aProperty == kABPersonFirstNamePhoneticProperty) return NO;
    if (aProperty == kABPersonMiddleNamePhoneticProperty) return NO;
    if (aProperty == kABPersonLastNamePhoneticProperty) return NO;
    
    if (aProperty == kABPersonOrganizationProperty) return NO;
    if (aProperty == kABPersonJobTitleProperty) return NO;
    if (aProperty == kABPersonDepartmentProperty) return NO;
    
    if (aProperty == kABPersonNoteProperty) return NO;
    
    if (aProperty == kABPersonKindProperty) return NO;
    
    if (aProperty == kABPersonBirthdayProperty) return NO;
    if (aProperty == kABPersonCreationDateProperty) return NO;
    if (aProperty == kABPersonModificationDateProperty) return NO;
    
    return YES;
    
    /*
     if (aProperty == kABPersonEmailProperty) return YES; // multistring
     if (aProperty == kABPersonPhoneProperty) return YES; // multistring
     if (aProperty == kABPersonURLProperty) return YES; // multistring

     if (aProperty == kABPersonAddressProperty) return YES; // multivalue
     if (aProperty == kABPersonDateProperty) return YES; // multivalue
     if (aProperty == kABPersonInstantMessageProperty) return YES; // multivalue
     if (aProperty == kABPersonRelatedNamesProperty) return YES; // multivalue
     if (aProperty == kABPersonSocialProfileProperty) return YES; // multivalue
     */
}

// Determine whether the dictionary is a proper value/label item
+ (BOOL) isMultivalueDictionary: (NSDictionary *) dictionary
{
    if (dictionary.allKeys.count != 2) 
        return NO;
    if (!dictionary[@"value"])
        return NO;
    if (!dictionary[@"label"])
        return NO;
    
    return YES;
}

// Return multivalue-style dictionary
+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (value) dict[@"value"] = value;
    if (label) dict[@"label"] = (__bridge NSString *)label;
    return dict;
}

#pragma mark Accessing MultiValue Elements (value and label)

- (NSArray *) arrayForProperty: (ABPropertyID) anID
{
    CFTypeRef theProperty = ABRecordCopyValue(_record, anID);
    if (!theProperty) return nil;
    
    NSArray *items = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
    CFRelease(theProperty);
    return items;
}

- (NSArray *) labelsForProperty: (ABPropertyID) anID
{
    CFTypeRef theProperty = ABRecordCopyValue(_record, anID);
    if (!theProperty) return nil;

    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < ABMultiValueGetCount(theProperty); i++)
    {
        NSString *label = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(theProperty, i);
        if (label == NULL)
        {
            [labels addObject:@""];
        } else {
            [labels addObject:label];
        }
    }
    CFRelease(theProperty);
    return labels;
}

- (NSArray *) emailArray {return [self arrayForProperty:kABPersonEmailProperty];}
- (NSArray *) emailLabels {return [self labelsForProperty:kABPersonEmailProperty];}

- (NSArray *) phoneArray {return [self arrayForProperty:kABPersonPhoneProperty];}
- (NSArray *) phoneLabels {return [self labelsForProperty:kABPersonPhoneProperty];}

- (NSArray *) relatedNameArray {return [self arrayForProperty:kABPersonRelatedNamesProperty];}
- (NSArray *) relatedNameLabels {return [self labelsForProperty:kABPersonRelatedNamesProperty];}

- (NSArray *) urlArray {return [self arrayForProperty:kABPersonURLProperty];}
- (NSArray *) urlLabels {return [self labelsForProperty:kABPersonURLProperty];}

- (NSArray *) dateArray {return [self arrayForProperty:kABPersonDateProperty];}
- (NSArray *) dateLabels {return [self labelsForProperty:kABPersonDateProperty];}

- (NSArray *) addressArray {return [self arrayForProperty:kABPersonAddressProperty];}
- (NSArray *) addressLabels {return [self labelsForProperty:kABPersonAddressProperty];}

- (NSArray *) imArray {return [self arrayForProperty:kABPersonInstantMessageProperty];}
- (NSArray *) imLabels {return [self labelsForProperty:kABPersonInstantMessageProperty];}

- (NSArray *) socialArray {return [self arrayForProperty:kABPersonSocialProfileProperty];}
- (NSArray *) socialLabels {return [self labelsForProperty:kABPersonSocialProfileProperty];}

// Multi-string convenience
- (NSString *) phonenumbers {return [self.phoneArray componentsJoinedByString:@" "];}
- (NSString *) emailaddresses {return [self.emailArray componentsJoinedByString:@" "];}
- (NSString *) urls {return [self.urlArray componentsJoinedByString:@" "];}

// MultiValue convenience
- (NSArray *) dictionaryArrayForProperty: (ABPropertyID) aProperty
{
    NSArray *valueArray = [self arrayForProperty:aProperty];
    NSArray *labelArray = [self labelsForProperty:aProperty];
    
    int num = MIN(valueArray.count, labelArray.count);
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < num; i++)
    {
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        md[@"value"] = valueArray[i];
        md[@"label"] = labelArray[i];
        [items addObject:md];
    }
    return items;
}

#pragma mark MultiValue Dictionary Arrays

- (NSArray *) emailDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonEmailProperty];
}

- (NSArray *) phoneDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonPhoneProperty];
}

- (NSArray *) relatedNameDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonRelatedNamesProperty];
}

- (NSArray *) urlDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonURLProperty];
}

- (NSArray *) dateDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonDateProperty];
}

- (NSArray *) addressDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonAddressProperty];
}

- (NSArray *) imDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonInstantMessageProperty];
}

- (NSArray *) socialDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonSocialProfileProperty];
}

#pragma mark Building Addresses, Social, and IM

/*
// kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
// kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
*/
+ (NSDictionary *) addressWithStreet: (NSString *) street withCity: (NSString *) city
                           withState:(NSString *) state withZip: (NSString *) zip
                         withCountry: (NSString *) country withCode: (NSString *) code
{
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if (street) md[(__bridge NSString *) kABPersonAddressStreetKey] = street;
    if (city) md[(__bridge NSString *) kABPersonAddressCityKey] = city;
    if (state) md[(__bridge NSString *) kABPersonAddressStateKey] = state;
    if (zip) md[(__bridge NSString *) kABPersonAddressZIPKey] = zip;
    if (country) md[(__bridge NSString *) kABPersonAddressCountryKey] = country;
    if (code) md[(__bridge NSString *) kABPersonAddressCountryCodeKey] = code;
    return md;
}

/*
 Service Names:
 const CFStringRef kABPersonSocialProfileServiceTwitter;
 const CFStringRef kABPersonSocialProfileServiceGameCenter;
 const CFStringRef kABPersonSocialProfileServiceFacebook;
 const CFStringRef kABPersonSocialProfileServiceMyspace;
 const CFStringRef kABPersonSocialProfileServiceLinkedIn;
 const CFStringRef kABPersonSocialProfileServiceFlickr;
*/
+ (NSDictionary *) socialWithURL: (NSString *) url withService: (NSString *) serviceName 
                    withUsername: (NSString *) username withIdentifier: (NSString *) key
{
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    if (url) md[(__bridge NSString *) kABPersonSocialProfileURLKey] = url;
    if (serviceName) md[(__bridge NSString *) kABPersonSocialProfileServiceKey] = serviceName;
    if (username) md[(__bridge NSString *) kABPersonSocialProfileUsernameKey] = username;
    if (key) md[(__bridge NSString *) kABPersonSocialProfileUserIdentifierKey] = key;
    return md;
}

/*
 // kABWorkLabel, kABHomeLabel, kABOtherLabel, 
 const CFStringRef kABPersonInstantMessageServiceYahoo;
 const CFStringRef kABPersonInstantMessageServiceJabber;
 const CFStringRef kABPersonInstantMessageServiceMSN;
 const CFStringRef kABPersonInstantMessageServiceICQ;
 const CFStringRef kABPersonInstantMessageServiceAIM;
 const CFStringRef kABPersonInstantMessageServiceFacebook;
 const CFStringRef kABPersonInstantMessageServiceGaduGadu;
 const CFStringRef kABPersonInstantMessageServiceGoogleTalk;
 const CFStringRef kABPersonInstantMessageServiceQQ;
 const CFStringRef kABPersonInstantMessageServiceSkype;
*/
+ (NSDictionary *) imWithService: (CFStringRef) service andUser: (NSString *) userName
{
    NSMutableDictionary *im = [NSMutableDictionary dictionary];
    if (service) im[(__bridge NSString *) kABPersonInstantMessageServiceKey] = (__bridge NSString *) service;
    if (userName) im[(__bridge NSString *) kABPersonInstantMessageUsernameKey] = userName;
    return im;
}

#pragma mark MultiValue Addition Utilities

- (BOOL) addAddress: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;

    NSArray *current = self.addressDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.addressDictionaries = mutable;

    return YES;
}

- (BOOL) addAddressItem:(NSDictionary *)dictionary withLabel: (CFStringRef) label
{
    if (!dictionary) return NO;
    if ([ABContact isMultivalueDictionary:dictionary]) 
        return [self addAddress:dictionary];
    
    NSDictionary *multi = [ABContact dictionaryWithValue:dictionary andLabel:label];
    return [self addAddress:multi];
}

- (BOOL) addIM: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.imDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.imDictionaries = mutable;
    
    return YES;
}

- (BOOL) addIMItem:(NSDictionary *)dictionary withLabel: (CFStringRef) label
{
    if (!dictionary) return NO;
    if ([ABContact isMultivalueDictionary:dictionary]) 
        return [self addIM:dictionary];
    
    NSDictionary *multi = [ABContact dictionaryWithValue:dictionary andLabel:label];
    return [self addIM:multi];
}


- (BOOL) addEmail: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.emailDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.emailDictionaries = mutable;
    
    return YES;
}

- (BOOL) addEmailItem: (NSString *) value withLabel: (CFStringRef) label
{
    if (!value) return NO;
    NSDictionary *multi = [ABContact dictionaryWithValue:value andLabel:label];
    return [self addEmail:multi];
}

- (BOOL) addPhone: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.phoneDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.phoneDictionaries = mutable;
    
    return YES;
}

- (BOOL) addPhoneItem: (NSString *) value withLabel: (CFStringRef) label
{
    if (!value) return NO;
    NSDictionary *multi = [ABContact dictionaryWithValue:value andLabel:label];
    return [self addPhone:multi];
}

- (BOOL) addURL: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.urlDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.urlDictionaries = mutable;
    
    return YES;
}

- (BOOL) addURLItem: (NSString *) value withLabel: (CFStringRef) label
{
    if (!value) return NO;
    NSDictionary *multi = [ABContact dictionaryWithValue:value andLabel:label];
    return [self addURL:multi];
}

- (BOOL) addRelation: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.relatedNameDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.relatedNameDictionaries = mutable;
    
    return YES;
}

- (BOOL) addRelationItem: (NSString *) value withLabel: (CFStringRef) label
{
    if (!value) return NO;
    NSDictionary *multi = [ABContact dictionaryWithValue:value andLabel:label];
    return [self addRelation:multi];
}

- (BOOL) addSocial: (NSDictionary *) dictionary
{
    if (!dictionary) return NO;
    if (![ABContact isMultivalueDictionary:dictionary]) return NO;
    
    NSArray *current = self.socialDictionaries;
    NSMutableArray *mutable = [NSMutableArray array];
    if (current)
        [mutable addObjectsFromArray:current];
    [mutable addObject:dictionary];
    self.socialDictionaries = mutable;
    
    return YES;
}

- (BOOL) addSocialItem: (NSDictionary *) dictionary withLabel: (CFStringRef) label
{
    if (!dictionary) return NO;
    if ([ABContact isMultivalueDictionary:dictionary]) 
        return [self addSocial:dictionary];
    
    NSDictionary *multi = [ABContact dictionaryWithValue:dictionary andLabel:label];
    return [self addSocial:multi];
}

#pragma mark Setting MultiValue

- (BOOL) setMultiValue: (ABMutableMultiValueRef) multi forProperty: (ABPropertyID) anID
{
    CFErrorRef errorRef = NULL;
    BOOL success = ABRecordSetValue(_record, anID, multi, &errorRef);
    if (!success) 
    {
        NSError *error = (__bridge_transfer NSError *) errorRef;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return success;
}

- (ABMutableMultiValueRef) copyMultiValueFromArray: (NSArray *) anArray withType: (ABPropertyType) aType
{
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(aType);
    for (NSDictionary *dict in anArray)
    {
        if (![ABContact isMultivalueDictionary:dict])
            continue;
        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef) dict[@"value"], (__bridge CFTypeRef) dict[@"label"], NULL);
    }
    return multi;
}

- (void) setEmailDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonEmailProperty];
    CFRelease(multi);
}

- (void) setPhoneDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel
    // kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhonePagerLabel
    // kABPersonPhoneOtherFAXLabel

    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonPhoneProperty];
    CFRelease(multi);
}

- (void) setUrlDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonHomePageLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonURLProperty];
    CFRelease(multi);
}

// Now fully supported in iOS
- (void) setRelatedNameDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonMotherLabel, kABPersonFatherLabel, kABPersonParentLabel, 
    // kABPersonSisterLabel, kABPersonBrotherLabel, kABPersonChildLabel, 
    // kABPersonFriendLabel, kABPersonSpouseLabel, kABPersonPartnerLabel, 
    // kABPersonManagerLabel, kABPersonAssistantLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonRelatedNamesProperty];
    CFRelease(multi);
}

- (void) setDateDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonAnniversaryLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDateTimePropertyType];
    [self setMultiValue:multi forProperty:kABPersonDateProperty];
    CFRelease(multi);
}

- (void) setAddressDictionaries: (NSArray *) dictionaries
{
    // kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
    // kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
    [self setMultiValue:multi forProperty:kABPersonAddressProperty];
    CFRelease(multi);
}

- (void) setImDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel, 
    // kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey
    // kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber
    // kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ
    // kABPersonInstantMessageServiceAIM, 
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
    [self setMultiValue:multi forProperty:kABPersonInstantMessageProperty];
    CFRelease(multi);
}

- (void) setSocialDictionaries:(NSArray *)dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel, 
    // kABPersonSocialProfileServiceTwitter
    // kABPersonSocialProfileServiceGameCenter
    // kABPersonSocialProfileServiceFacebook
    // kABPersonSocialProfileServiceMyspace
    // kABPersonSocialProfileServiceLinkedIn
    // kABPersonSocialProfileServiceFlickr

    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
    [self setMultiValue:multi forProperty:kABPersonSocialProfileProperty];
    CFRelease(multi);
}

#pragma mark Representations

// No Image
- (NSDictionary *) baseDictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.firstname) dict[FIRST_NAME_STRING] = self.firstname;
    if (self.middlename) dict[MIDDLE_NAME_STRING] = self.middlename;
    if (self.lastname) dict[LAST_NAME_STRING] = self.lastname;

    if (self.prefix) dict[PREFIX_STRING] = self.prefix;
    if (self.suffix) dict[SUFFIX_STRING] = self.suffix;
    if (self.nickname) dict[NICKNAME_STRING] = self.nickname;
    
    if (self.firstnamephonetic) dict[PHONETIC_FIRST_STRING] = self.firstnamephonetic;
    if (self.middlenamephonetic) dict[PHONETIC_MIDDLE_STRING] = self.middlenamephonetic;
    if (self.lastnamephonetic) dict[PHONETIC_LAST_STRING] = self.lastnamephonetic;
    
    if (self.organization) dict[ORGANIZATION_STRING] = self.organization;
    if (self.jobtitle) dict[JOBTITLE_STRING] = self.jobtitle;
    if (self.department) dict[DEPARTMENT_STRING] = self.department;
    
    if (self.note) dict[NOTE_STRING] = self.note;

    if (self.kind) dict[KIND_STRING] = self.kind;

    if (self.birthday) dict[BIRTHDAY_STRING] = self.birthday;
    if (self.creationDate) dict[CREATION_DATE_STRING] = self.creationDate;
    if (self.modificationDate) dict[MODIFICATION_DATE_STRING] = self.modificationDate;

    dict[EMAIL_STRING] = self.emailDictionaries;
    dict[ADDRESS_STRING] = self.addressDictionaries;
    dict[DATE_STRING] = self.dateDictionaries;
    dict[PHONE_STRING] = self.phoneDictionaries;
    dict[IM_STRING] = self.imDictionaries;
    dict[URL_STRING] = self.urlDictionaries;
    dict[RELATED_STRING] = self.relatedNameDictionaries;
    
    return dict;
}

// With image where available
- (NSDictionary *) dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self baseDictionaryRepresentation]];
    if (ABPersonHasImageData(_record)) 
    {
        CFDataRef imageData = ABPersonCopyImageData(_record);
        NSData *data = (__bridge_transfer NSData *)imageData;
        dict[IMAGE_STRING] = data;
    }
    return dict;
}

// No Image
- (NSData *) baseDataRepresentation
{
    NSString *errorString;
    NSDictionary *dict = [self baseDictionaryRepresentation];
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
    if (!data) 
        NSLog(@"Error: %@", errorString);
    return data; 
}


// With image where available
- (NSData *) dataRepresentation
{
    NSString *errorString;
    NSDictionary *dict = [self dictionaryRepresentation];
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
    if (!data) 
        NSLog(@"Error: %@", errorString);
    return data;
}

+ (id) contactWithDictionary: (NSDictionary *) dict
{
    ABContact *contact = [ABContact contact];
    if (dict[FIRST_NAME_STRING]) 
        contact.firstname = dict[FIRST_NAME_STRING];
    if (dict[MIDDLE_NAME_STRING]) 
        contact.middlename = dict[MIDDLE_NAME_STRING];
    if (dict[LAST_NAME_STRING]) 
        contact.lastname = dict[LAST_NAME_STRING];
    
    if (dict[PREFIX_STRING]) 
        contact.prefix = dict[PREFIX_STRING];
    if (dict[SUFFIX_STRING]) 
        contact.suffix = dict[SUFFIX_STRING];
    if (dict[NICKNAME_STRING]) 
        contact.nickname = dict[NICKNAME_STRING];
    
    if (dict[PHONETIC_FIRST_STRING]) 
        contact.firstnamephonetic = dict[PHONETIC_FIRST_STRING];
    if (dict[PHONETIC_MIDDLE_STRING]) 
        contact.middlenamephonetic = dict[PHONETIC_MIDDLE_STRING];
    if (dict[PHONETIC_LAST_STRING]) 
        contact.lastnamephonetic = dict[PHONETIC_LAST_STRING];
    
    if (dict[ORGANIZATION_STRING]) 
        contact.organization = dict[ORGANIZATION_STRING];
    if (dict[JOBTITLE_STRING]) 
        contact.jobtitle = dict[JOBTITLE_STRING];
    if (dict[DEPARTMENT_STRING]) 
        contact.department = dict[DEPARTMENT_STRING];
    
    if (dict[NOTE_STRING]) 
        contact.note = dict[NOTE_STRING];
    
    if (dict[KIND_STRING]) 
        contact.kind = dict[KIND_STRING];

    if (dict[EMAIL_STRING]) 
        contact.emailDictionaries = dict[EMAIL_STRING];
    if (dict[ADDRESS_STRING]) 
        contact.addressDictionaries = dict[ADDRESS_STRING];
    if (dict[DATE_STRING])
        contact.dateDictionaries = dict[DATE_STRING];
    if (dict[PHONE_STRING]) 
        contact.phoneDictionaries = dict[PHONE_STRING];
    if (dict[IM_STRING]) 
        contact.imDictionaries = dict[IM_STRING];
    if (dict[URL_STRING]) 
        contact.urlDictionaries = dict[URL_STRING];
    if (dict[RELATED_STRING]) 
        contact.relatedNameDictionaries = dict[RELATED_STRING];

    if (dict[IMAGE_STRING]) 
    {
        CFErrorRef errorRef = NULL;
         BOOL success = ABPersonSetImageData(contact.record, (__bridge CFDataRef) dict[IMAGE_STRING], &errorRef);
        if (!success) 
        {
            NSError *error = (__bridge_transfer NSError *) errorRef;
            NSLog(@"Error: %@", error.localizedFailureReason);
        }
    }

    return contact;
}

+ (id) contactWithData: (NSData *) data
{
    // Otherwise handle points
    CFStringRef errorString;
    CFPropertyListRef plist = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)data, kCFPropertyListMutableContainers, &errorString);
    if (!plist) 
    {
        CFShow(errorString);
        return nil;
    }
    
    NSDictionary *dict = (__bridge_transfer NSDictionary *) plist;
    return [self contactWithDictionary:dict];
}
@end