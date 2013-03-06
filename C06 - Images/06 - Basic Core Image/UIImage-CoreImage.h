/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface UIImage (CoreImageRecipes)
- (UIImage *) sepiaVersion: (CGFloat) intensity;
- (UIImage *) perspectiveExample;
- (UIImage *) pinchDistortionExample;
- (UIImage *) bloomExample;
@property (nonatomic, readonly) CIImage *coreImageRepresentation;
@end
