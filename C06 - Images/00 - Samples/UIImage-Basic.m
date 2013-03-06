/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIImage-Basic.h"

@implementation UIImage (Basic)

// Return a swatch with the given color
- (UIImage *) swatchWithColor:(UIColor *) color andSize: (CGFloat) side
{
	UIGraphicsBeginImageContext(CGSizeMake(side, side));
	CGContextRef context = UIGraphicsGetCurrentContext();
	[color setFill];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, side, side));
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
}

@end


