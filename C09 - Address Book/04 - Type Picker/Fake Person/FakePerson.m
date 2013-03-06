/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "FakePerson.h"

// Webservius: http://www.fakenamegenerator.com/api.php
// Other services:
// http://igorbass.com/rand/
// http://www.identitygenerator.com/

@implementation FakePerson

+ (ABContact *) contactWithIdentity: (NSDictionary *) identity
{
    if (!identity) return nil;    
    ABContact *contact = [ABContact contact];
    
    contact.firstname = identity[@"givenname"];
    contact.middlename = identity[@"middleinitial"];
    contact.lastname = identity[@"surname"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;    
    NSString *birthday = identity[@"birthday"];
    contact.birthday = [formatter dateFromString:birthday];
    
    // Multivalue items
    NSDictionary *address = [ABContact addressWithStreet:identity[@"streetaddress"]
                                                withCity:identity[@"city"]
                                               withState:identity[@"state"]
                                                 withZip:identity[@"zipcode"]
                                             withCountry:identity[@"country"] 
                                                withCode:nil];
    NSMutableArray *addresses = [NSMutableArray array];
    [addresses addObject:[ABContact dictionaryWithValue:address
                                               andLabel:kABHomeLabel]];
    contact.addressDictionaries = addresses;
    
    NSMutableArray *emails = [NSMutableArray array];
    [emails addObject:[ABContact dictionaryWithValue:identity[@"emailaddress"]
                                            andLabel:kABWorkLabel]];
    contact.emailDictionaries = emails;
    
    NSMutableArray *phones = [NSMutableArray array];
    [phones addObject:[ABContact dictionaryWithValue:identity[@"telephonenumber"]
                                            andLabel:kABPersonPhoneMobileLabel]];
    contact.phoneDictionaries = phones;
    
    NSMutableArray *urls = [NSMutableArray array];
    [urls addObject:[ABContact dictionaryWithValue:identity[@"domain"]
                                          andLabel:kABPersonHomePageLabel]];
    contact.urlDictionaries = urls;
    
    contact.note = @"FakePersonGeneration";
    return contact;
}

#define GETINDEX(ATTRIBUTE) [ATTRIBUTES indexOfObject:ATTRIBUTE]
+ (NSDictionary *) fetchIdentity
{
    static BOOL seeded = NO;
    if (!seeded) {seeded = YES; srand(time(NULL));}

    static NSMutableArray *identities = nil;
    if (!identities)
    {
        NSLog(@"Building fake identities base");
        NSString *dataString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FakePersons" ofType:@"csv"] encoding:NSUTF8StringEncoding error:nil];
        NSArray *lineArray = [dataString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        identities = [NSMutableArray array];
        
        for (NSString *line in lineArray)
        {
            NSArray *items = [line componentsSeparatedByString:@","];
            if (items.count != ATTRIBUTES.count) continue;
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (NSString *attribute in ATTRIBUTES)
                dict[attribute] = items[GETINDEX(attribute)];
            [identities addObject:dict];
        }
    }
    
    if (!identities)
        return nil;
    
    NSDictionary *identity = identities[rand() % identities.count];
    return identity;
}

+ (ABContact *) randomPerson
{
    NSDictionary *identity = [self fetchIdentity];
    if (!identity) return nil;
    
    ABContact *contact = [self contactWithIdentity:identity];
    return contact;
}
@end
