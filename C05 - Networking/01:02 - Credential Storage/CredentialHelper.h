/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface CredentialHelper : NSObject
+ (id) helperWithHost: (NSString *) host;

- (void) storeCredential: (NSString *)value forKey: (NSString *) key;
- (void) storeDefaultCredential: (NSString *) value forKey: (NSString *) key;
- (NSURLCredential *) credentialForKey: (NSString *) key;
- (NSURLCredential *) defaultCredential;
- (NSString *) valueForKey: (NSString *) key;

- (id) objectForKeyedSubscript: (NSString *) key;
- (void) setObject: (NSString *) newValue forKeyedSubscript: (NSString *) aKey;

- (void) removeCredential: (NSString *) key;
- (void) removeAllCredentials;

@property (nonatomic) NSString *host;
@property (nonatomic, readonly) NSURLProtectionSpace *protectionSpace;
@property (nonatomic, readonly) NSDictionary *credentials;
@property (nonatomic, readonly) NSInteger credentialCount;
@end
