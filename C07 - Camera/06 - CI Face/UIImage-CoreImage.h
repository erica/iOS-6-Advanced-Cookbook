/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface UIImage (CoreImageUtility)
+ (UIImage *) imageWithCIImage: (CIImage *) aCIImage orientation: (UIImageOrientation) anOrientation;
@property (nonatomic, readonly) CIImage *coreImageRepresentation;
@end
