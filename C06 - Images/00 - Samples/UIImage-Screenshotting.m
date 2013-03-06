/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import "UIImage-Screenshotting.h"
#import "Utility.h"

@implementation UIImage (Screenshotting)
// Screen shot the view
+ (UIImage *) imageFromView: (UIView *) theView
{
	UIGraphicsBeginImageContext(theView.frame.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	[theView.layer renderInContext:context];
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
	return theImage;
}

+ (void) saveImage: (UIImage *) image toPDFFile: (NSString *) path
{
    CGRect theBounds = (CGRect){.size=image.size};
    UIGraphicsBeginPDFContextToFile(path, theBounds, nil);
    {
        UIGraphicsBeginPDFPage();
        [image drawInRect:theBounds];
    }
    UIGraphicsEndPDFContext();
}

+ (void) performScreenshot
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIImage *screenshot = [self imageFromView:window];
    NSString *destination = [NSHomeDirectory() stringByAppendingString:@"/Documents/Screenshot.pdf"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:destination])
        [[NSFileManager defaultManager] removeItemAtPath:destination error:nil];
    [self saveImage:screenshot toPDFFile:destination];
}
@end