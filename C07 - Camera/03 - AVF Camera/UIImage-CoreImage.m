/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIImage-CoreImage.h"
#import <CoreImage/CoreImage.h>
#import "Utility.h"

@implementation UIImage (CoreImageUtility)
- (CIImage *) coreImageRepresentation
{
    if (self.CIImage)
        return self.CIImage;
    return [CIImage imageWithCGImage:self.CGImage];
}

+ (UIImage *) imageWithCIImage: (CIImage *) aCIImage orientation: (UIImageOrientation) anOrientation
{
    if (!aCIImage) return nil;
    
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:aCIImage fromRect:aCIImage.extent];
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:anOrientation];
    CFRelease(cgImage);
    
    return image;
}
@end
