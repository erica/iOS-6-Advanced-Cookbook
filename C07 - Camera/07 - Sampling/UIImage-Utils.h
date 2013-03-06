/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark Bitmap Offsets
// ARGB Offset Helpers
NSUInteger alphaOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger redOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger greenOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger blueOffset(NSUInteger x, NSUInteger y, NSUInteger w);

@interface UIImage (Utils)
- (UIImage *) subImageWithBounds:(CGRect) rect;
+ (UIImage *) imageWithBytes: (Byte *) bits withSize: (CGSize) size;
+ (NSData *) bytesFromImage: (UIImage *) image;
@property (nonatomic, readonly) NSData *bytes;
@end
