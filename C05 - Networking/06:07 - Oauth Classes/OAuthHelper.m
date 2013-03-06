/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <CommonCrypto/CommonHMAC.h>

#import "OAuthHelper.h"
#import "OAuthRequestSigner.h"
#import "CredentialHelper.h"
#import "Utility.h"

@implementation OAuthHelper
{
    CredentialHelper *credentialHelper;
}

#pragma mark - Convenience

+ (id) helperWithHost: (NSString *) hostName
{
    OAuthHelper *helper = [[OAuthHelper alloc] init];
    helper.host = hostName;
    [helper setupCredentialHelper];
    return helper;
}

- (void) setupCredentialHelper
{
    if (!_host) return;
    credentialHelper = [CredentialHelper helperWithHost:_host];
}

#pragma mark - Debug

- (NSString *) description
{
    NSMutableString *outstring = [NSMutableString string];
    [outstring appendFormat:@"user token: %@; ", credentialHelper[@"oauth_token"]];
    [outstring appendFormat:@"user secret: %@; ", credentialHelper[@"oauth_token_secret"]];
    [outstring appendFormat:@"host: %@; ", _host];
    [outstring appendFormat:@"consumerKey: %@; ", _consumerKey];
    [outstring appendFormat:@"consumerSecret: %@; ", _consumerSecret];
    return outstring;
}

- (void) listCredentials
{
    // Never log passwords in production code
    NSLog(@"Protection space for %@ has %d credentials:", _host, credentialHelper.credentialCount);
    for (NSString *userName in credentialHelper.credentials.allKeys)
        NSLog(@"%@: %@", userName, credentialHelper[userName]);
}

- (void) cleanUpVerifier
{
    [credentialHelper removeCredential:@"oauth_verifier"];
    [credentialHelper removeCredential:@"authenticated"];
}

#pragma mark - Token Exchange
- (NSMutableDictionary *) baseDictionary
{
    if (!_host) { NSLog(@"Host is undefined"); return nil; }
    if (!_consumerKey) { NSLog(@"Consumer key is undefined"); return nil; }
    if (!_consumerSecret) { NSLog(@"Consumer secret is undefined"); return nil; }
    return [OAuthRequestSigner oauthBaseDictionary:_consumerKey];
}

// Process and store tokens
- (BOOL) processTokens: (NSData *) tokenData
{
    NSString *tokenResultString = DATASTR(tokenData);

    // Check that we've received the right data
    NSRange range = [tokenResultString rangeOfString:@"oauth_token_secret"];
    if (range.location == NSNotFound)
    {
        NSLog(@"Failed to retrieve tokens: %@", tokenResultString);
        return NO;
    }
    
    // Convert the tokens
    NSDictionary *tokens = [OAuthRequestSigner dictionaryFromParameterString:tokenResultString];
    if (!tokens)
    {
        NSLog(@"Unable to process tokens: %@", tokenResultString);
        return NO;
    }
    
    // Store the tokens
    for (NSString *key in tokens.allKeys)
        credentialHelper[key] = tokens[key];
    
    return YES;    
}

// Request initial tokens
- (BOOL) requestTokens: (NSString *) tokenEndpoint
{
    NSURL *endpointURL = [NSURL URLWithString:tokenEndpoint];
    
	// Create the preliminary (no token) dictionary
	NSMutableDictionary *dict = [self baseDictionary];
    if (!dict) return NO;

	// Create signature
    NSMutableString *baseRequest = [OAuthRequestSigner baseRequestWithEndpoint:tokenEndpoint dictionary:dict andRequestMethod:@"POST"];
    NSString *secretKey = [_consumerSecret stringByAppendingString:@"&"];
    dict[@"oauth_signature"] = [OAuthRequestSigner signRequest:baseRequest withKey:secretKey];

    // Produce the token request
    NSString *bodyString = [OAuthRequestSigner parameterStringFromDictionary:dict];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpointURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = STRDATA(bodyString);
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Request the tokens
    NSError *error;
	NSURLResponse *response;
	NSData *tokenData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!tokenData)
    {
        NSLog(@"Failed to retrieve tokens: %@", error.localizedFailureReason);
        return NO;
    }
    return [self processTokens:tokenData];
}

// Finish the end-user authentication step
- (BOOL) authenticate: (NSString *) accessEndpoint
{
    NSURL *endpointURL = [NSURL URLWithString:accessEndpoint];
    
    // This verifier invalidates after use
    NSString *access_verifier = credentialHelper[@"oauth_verifier"];
    if (!access_verifier)
    {
        NSLog(@"Error: Expected but did not find verifier");
        return NO;
    }
    
    // Add the token and verifier
	NSMutableDictionary *dict = [self baseDictionary];
    if (!dict) return NO;
    dict[@"oauth_token"] = credentialHelper[@"oauth_token"];
    dict[@"oauth_verifier"] = credentialHelper[@"oauth_verifier"];
	
	// Create signature
    NSMutableString *baseRequest = [OAuthRequestSigner baseRequestWithEndpoint:accessEndpoint dictionary:dict andRequestMethod:@"POST"];
    NSString *compositeKey = [NSString stringWithFormat:@"%@&%@", _consumerSecret, credentialHelper[@"oauth_token_secret"]];    
    dict[@"oauth_signature"] = [OAuthRequestSigner signRequest:baseRequest withKey:compositeKey];
    
    // Build the request
    NSString *bodyString = [OAuthRequestSigner parameterStringFromDictionary:dict];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpointURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = STRDATA(bodyString);
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    // Place the request
    NSError *error;
	NSURLResponse *response;
	NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    // Check for common issues
	if (!resultData)
    {
        NSLog(@"Failed to retrieve tokens: %@", error.localizedFailureReason);
        return NO;
    }
    
    // Convert results to a string
    NSString *resultString = DATASTR(resultData);
    if (!resultString)
    {
        NSLog(@"Expected but did not get result string with tokens");
        return NO;
    }
    
    // Process the tokens
    NSDictionary *tokens = [OAuthRequestSigner dictionaryFromParameterString:resultString];
    if ([tokens.allKeys containsObject:@"oauth_token_secret"])
    {
        NSLog(@"Success. App is verified.");
        for (NSString *key in tokens.allKeys)
            credentialHelper[key] = tokens[key];
        
        // Clean up
        [credentialHelper removeCredential:@"oauth_verifier"];
        credentialHelper[@"authenticated"] = @"YES";
    }
    return YES;
}

// Demonstrate an authenticated "GET"
- (NSData *) performGetRequest:(NSString *) endpoint
{
    // Add oauth token to dictionary
    NSMutableDictionary *dict = [self baseDictionary];
    if (!dict) return NO;
    dict[@"oauth_token"] = credentialHelper[@"oauth_token"];
	
	// Create signature
    NSMutableString *baseRequest = [OAuthRequestSigner baseRequestWithEndpoint:endpoint dictionary:dict andRequestMethod:@"GET"];    
    NSString *compositeKey = [NSString stringWithFormat:@"%@&%@", _consumerSecret, credentialHelper[@"oauth_token_secret"]];
    dict[@"oauth_signature"] = [OAuthRequestSigner signRequest:baseRequest withKey:compositeKey];

    // Set up the request
    NSString *bodyString = [OAuthRequestSigner parameterStringFromDictionary:dict];
    NSString *requestString = [endpoint stringByAppendingFormat:@"?%@", bodyString];

	// Produce the request URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    request.HTTPMethod = @"GET";
    
    // Place the request
    NSError *error;
	NSURLResponse *response;
	NSData *resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    return resultData;
}
@end
