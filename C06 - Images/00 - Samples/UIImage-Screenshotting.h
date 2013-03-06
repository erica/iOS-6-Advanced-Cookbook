/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (Screenshotting)
+ (UIImage *) imageFromView: (UIView *) theView;
+ (void) saveImage: (UIImage *) image toPDFFile: (NSString *) path;
+ (void) performScreenshot;
@end
