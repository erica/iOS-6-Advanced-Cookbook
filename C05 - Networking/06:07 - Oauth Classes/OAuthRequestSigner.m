/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <CommonCrypto/CommonHMAC.h>

#import "OAuthRequestSigner.h"
#import "CredentialHelper.h"
#import "NSData+Base64.h"
#import "Utility.h"

@implementation OAuthRequestSigner
{
    CredentialHelper *credentialHelper;
}

// Sign the clear text with the secret key
+ (NSString *) signClearText: (NSString *)text withKey: (NSString *) secret
{
    NSData *secretData = STRDATA(secret);
    NSData *clearTextData = STRDATA(text);
	
    //HMAC-SHA1
    CCHmacContext hmacContext;
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    CCHmacInit(&hmacContext, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
	CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
    CCHmacFinal(&hmacContext, digest);
	
	// Convert to a base64-encoded result, thanks to Matt Gallagher's NSData category
	NSData *out = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
	return [out base64EncodedString];
}

// RFC 3986
+ (NSString *) urlEncodedString: (NSString *) string
{
	NSString *result = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string,  NULL,  CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
    return result;
}

// Return encoded signed request
+ (NSString *) signRequest: (NSString *) baseRequest withKey: (NSString *) secret
{
    NSString *signedRequest = [OAuthRequestSigner signClearText:baseRequest withKey:secret];
    NSString *encodedRequest = [OAuthRequestSigner urlEncodedString:signedRequest];
    return encodedRequest;
}

// Return a nonce
+ (NSString *) oauthNonce;
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	NSString *nonceString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return nonceString;
}

// Build a token dictionary from a key=value&key=value&key=value string
+ (NSDictionary *) dictionaryFromParameterString: (NSString *) resultString
{
    if (!resultString) return nil;
    NSMutableDictionary *tokens = [NSMutableDictionary dictionary];
    NSArray *pairs = [resultString componentsSeparatedByString:@"&"];
    for (NSString *pairString in pairs)
    {
        NSArray *pair = [pairString componentsSeparatedByString:@"="];
        if (pair.count != 2) continue;
        tokens[pair[0]] = pair[1];
    }
    return tokens;
}

// Build a string from an oauth dictionary
+ (NSString *) parameterStringFromDictionary: (NSDictionary *) dict
{
	NSMutableString *outString = [NSMutableString string];
	
	// Sort keys
	NSMutableArray *keys = [NSMutableArray arrayWithArray:[dict allKeys]];
	[keys sortUsingSelector:@selector(caseInsensitiveCompare:)];
	
	// Add sorted items to parameter string
	for (int i = 0; i < keys.count; i++)
	{
		NSString *key = keys[i];
		[outString appendFormat:@"%@=%@", key, dict[key]];
		if (i < (keys.count - 1))
            [outString appendString:@"&"];
	}
	
	return outString;
}

// Create a base oauth dictionary
+ (NSMutableDictionary *) oauthBaseDictionary: (NSString *) consumerKey;
{
 	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"oauth_consumer_key"] = consumerKey;
    dict[@"oauth_nonce"] =  [OAuthRequestSigner oauthNonce];
    dict[@"oauth_signature_method"] = @"HMAC-SHA1";
    dict[@"oauth_timestamp"] = [NSString stringWithFormat:@"%d", (int)time(0)];
    dict[@"oauth_version"] = @"1.0";
	return dict;
}

+ (NSMutableString *) baseRequestWithEndpoint: (NSString *) endPoint dictionary: (NSDictionary *)dict andRequestMethod: (NSString *) method
{
    NSMutableString *baseRequest = [NSMutableString string];
    NSString *encodedEndpoint = [OAuthRequestSigner urlEncodedString:endPoint];
    [baseRequest appendString: [NSString stringWithFormat:@"%@&%@&", method, encodedEndpoint]];
    NSString *baseParameterString = [OAuthRequestSigner parameterStringFromDictionary:dict];
    NSString *encodedParamString = [OAuthRequestSigner urlEncodedString:baseParameterString];
    [baseRequest appendString:encodedParamString];
    return baseRequest;
}
@end
