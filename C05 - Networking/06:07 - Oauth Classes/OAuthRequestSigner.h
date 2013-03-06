/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface OAuthRequestSigner : NSObject
+ (NSMutableDictionary *) oauthBaseDictionary: (NSString *) consumerKey;

+ (NSString *) signClearText: (NSString *)text withKey: (NSString *) secret;
+ (NSString *) urlEncodedString: (NSString *) string;
+ (NSString *) signRequest: (NSString *) baseRequest withKey: (NSString *) secret;

// Build parameter string from dict
+ (NSString *) parameterStringFromDictionary: (NSDictionary *) dict;

// Build dict from parameter string
+ (NSDictionary *) dictionaryFromParameterString: (NSString *) resultString;

// Create a standard base request
+ (NSMutableString *) baseRequestWithEndpoint: (NSString *) endPoint dictionary: (NSDictionary *)dict andRequestMethod: (NSString *) method;
@end
