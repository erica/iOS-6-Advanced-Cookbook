/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface UIImage (vImage)
- (UIImage *) vImageRotate: (CGFloat) theta;
@property (nonatomic, readonly) vImage_Buffer buffer;
@end
