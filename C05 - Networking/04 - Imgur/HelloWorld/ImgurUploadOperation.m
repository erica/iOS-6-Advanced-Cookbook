/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ImgurUploadOperation.h"
#import "NSData+Base64.h" // Thanks Matt Gallagher

// This file is *my* API keys. Please use your own API keys.
// Register here: http://api.imgur.com/resources_anon
// #import "/Volumes/MusicAndData/Book Writing/66-6.0 Sample Code/API_Keys.h"

#error Define your own API Keys here
#define IMGUR_API_KEY   @"UNDEFINED"

#define NOTIFY_AND_LEAVE(MESSAGE) {[self bail:MESSAGE]; return;}
#define STRDATA(STRING) ([STRING dataUsingEncoding:NSUTF8StringEncoding])
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelectorOnMainThread:THE_SELECTOR withObject:THE_ARG waitUntilDone:NO] : nil)

@implementation ImgurUploadOperation

- (void) bail: (NSString *) message
{
    SAFE_PERFORM_WITH_ARG(_delegate, @selector(handleImgurOperationError:), message);
}

// Posting constants
#define IMAGE_CONTENT(_FILENAME_) @"Content-Disposition: form-data; name=\"%@\"; filename=\"_FILENAME_\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"

- (NSData*)generateFormDataFromPOSTDictionary:(NSDictionary*)dict
{
    NSString *boundary = @"------------0x0x0x0x0x0x0x0x";
    NSArray *keys = [dict allKeys];
    NSMutableData *result = [NSMutableData data];
	
    for (int i = 0; i < keys.count; i++)
    {
        // Start part
        id value = dict[keys[i]];
        NSString *start = [NSString stringWithFormat:@"--%@\r\n", boundary];
        [result appendData:STRDATA(start)];
		
		if ([value isKindOfClass:[NSData class]])
		{
			// handle image data
			NSString *formstring = [NSString stringWithFormat:IMAGE_CONTENT(@"Cookbook.jpg"), [keys objectAtIndex:i]];
			[result appendData:STRDATA(formstring)];
			[result appendData:value];
		}
		else
		{
			// all non-image fields assumed to be strings
			NSString *formstring = [NSString stringWithFormat:STRING_CONTENT, [keys objectAtIndex:i]];
			[result appendData: STRDATA(formstring)];
			[result appendData:STRDATA(value)];
		}
		
        // End of part
		NSString *formstring = @"\r\n";
        [result appendData:STRDATA(formstring)];
    }
	
    // End of form
	NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", boundary];
    [result appendData:STRDATA(formstring)];
    return result;
}

- (void) main
{
	if (!_image)
		NOTIFY_AND_LEAVE(@"ERROR: Please set image before uploading.");
    
    // Establish the post dictionary contents
	NSMutableDictionary *postDictionary = [NSMutableDictionary dictionary];
    postDictionary[@"key"] = IMGUR_API_KEY;
    postDictionary[@"title"] = @"Random Image";
    postDictionary[@"caption"] = @"Created by the iOS Developer's Cookbook";
    postDictionary[@"type"] = @"base64";
    postDictionary[@"image"] = [UIImageJPEGRepresentation(_image, 0.65) base64EncodedString];

	// Create the post data from the post dictionary
	NSData *postData = [self generateFormDataFromPOSTDictionary:postDictionary];
	
	// Establish the API request.
    NSString *baseurl = @"http://api.imgur.com/2/upload.json";
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"ERROR: Error creating the URL Request");
	
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
	
	// Submit & retrieve results
    NSError *error;
    NSURLResponse *response;
	// NSLog(@"Contacting site....");
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (!result)
	{
		[self bail:[NSString stringWithFormat:@"Submission error: %@", error.localizedFailureReason]];
		return;
	}
	
	// Return results
    SAFE_PERFORM_WITH_ARG(_delegate, @selector(finishedImgurOperationWithData:), result);
}

+ (id) operationWithDelegate: (id <ImgurUploadOperationDelegate>) delegate andImage: (UIImage *) image
{
    ImgurUploadOperation *op = [[ImgurUploadOperation alloc] init];
    op.delegate = delegate;
    op.image= image;    
    return op;
}
@end