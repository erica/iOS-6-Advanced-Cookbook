/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface UIImage (vImage)
- (UIImage *) vImageRotate: (CGFloat) theta;
- (UIImage *) vImageConvolve: (NSData *) kernel;
@property (nonatomic, readonly) vImage_Buffer buffer;

- (UIImage *) blur: (NSInteger) radius;
- (UIImage *) blur3;
- (UIImage *) blur5;

- (UIImage *) convolve: (const int16_t *) kernel side: (NSInteger) side;
- (UIImage *) emboss;
- (UIImage *) sharpen;
- (UIImage *) gauss5;
@end
