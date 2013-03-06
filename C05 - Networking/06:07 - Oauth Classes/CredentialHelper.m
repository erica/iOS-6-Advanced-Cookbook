/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "CredentialHelper.h"

@implementation CredentialHelper
+ (id) helperWithHost: (NSString *) host
{
    CredentialHelper *helper = [[CredentialHelper alloc] init];
    helper.host = host;
    return helper;
}

- (NSURLProtectionSpace *) protectionSpace
{
    if (!_host) return nil;
    return [[NSURLProtectionSpace alloc] initWithHost:_host port:0 protocol:@"http" realm:nil authenticationMethod:nil];
}

- (NSDictionary *) credentials
{
    if (!_host) return nil;
    
    NSDictionary *credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:self.protectionSpace];
    return credentials;
}

- (NSInteger) credentialCount
{
    if (!_host) return 0;
    return self.credentials.allKeys.count;
}

- (void) storeCredential: (NSString *) value forKey: (NSString *) key
{
    if (!_host)
    {
        NSLog(@"Error: Cannot store credential for nil host");
        return;
    }

    NSURLCredential *credential = [NSURLCredential credentialWithUser:key password:value persistence: NSURLCredentialPersistencePermanent];
    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:self.protectionSpace];
}

- (void) storeDefaultCredential: (NSString *) value forKey: (NSString *) key
{
    if (!_host)
    {
        NSLog(@"Error: Cannot store credential for nil host");
        return;
    }
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:key password:value persistence: NSURLCredentialPersistencePermanent];
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential forProtectionSpace:self.protectionSpace];
}

- (NSURLCredential *) defaultCredential
{
    return [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:self.protectionSpace];
}


- (void) removeCredential: (NSString *) key
{
    NSArray *keys = self.credentials.allKeys;
    if (![keys containsObject:key])
    {
        NSLog(@"Key %@ not found in credentials. Skipping remove request.", key);
        return;
    }
    [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:self.credentials[key] forProtectionSpace:self.protectionSpace];
}

- (void) removeAllCredentials
{
    NSArray *keys = self.credentials.allKeys;
    for (NSString *key in keys)
        [self removeCredential:key];
}

- (NSURLCredential *) credentialForKey: (NSString *) key
{
    if (!_host) return nil;
    return self.credentials[key];
}
 
- (NSString *) valueForKey:(NSString *)key
{
    NSURLCredential *credential = [self credentialForKey:key];
    if (!credential) return nil;
    return credential.password;
}

- (id) objectForKeyedSubscript: (NSString *) key
{
    return [self valueForKey:key];
}

- (void) setObject: (NSString *) newValue forKeyedSubscript: (NSString *) aKey
{
    [self storeCredential: newValue forKey: aKey];
}
@end
