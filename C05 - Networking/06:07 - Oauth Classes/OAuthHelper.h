/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>

@interface OAuthHelper : NSObject
+ (id) helperWithHost: (NSString *) hostName;

@property (nonatomic) NSString *host;
@property (nonatomic) NSString *consumerKey;
@property (nonatomic) NSString *consumerSecret;

- (BOOL) requestTokens: (NSString *) tokenEndpoint;
- (BOOL) authenticate: (NSString *) accessEndpoint;
- (NSData *) performGetRequest:(NSString *) endpoint;

// Debug utilities
- (void) listCredentials;
- (void) cleanUpVerifier;
@end
