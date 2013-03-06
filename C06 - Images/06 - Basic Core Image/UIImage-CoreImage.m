/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIImage-CoreImage.h"
#import <CoreImage/CoreImage.h>
#import "Utility.h"

@implementation UIImage (CoreImageRecipes)
- (CIImage *) coreImageRepresentation
{
    if (self.CIImage)
        return self.CIImage;
    return [CIImage imageWithCGImage:self.CGImage];
    // return [CIImage imageWithData:UIImageJPEGRepresentation(self, 1.0f)];
}

- (UIImage *) sepiaVersion: (CGFloat) intensity
{
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"
                                  keysAndValues: @"inputImage", self.coreImageRepresentation,
                        nil];
    [filter setDefaults];
    [filter setValue:@(intensity) forKey:@"inputIntensity"];
    
    CIImage *output = [filter valueForKey:kCIOutputImageKey];
    if (!output)
    {
        NSLog(@"Core Image processing error");
        return nil;
    }

    UIImage *results = [UIImage imageWithCIImage:output];
    return results;
}

- (UIImage *) perspectiveExample
{
    CIFilter *filter = [CIFilter filterWithName:@"CIPerspectiveTransform"
                                  keysAndValues: @"inputImage", self.coreImageRepresentation,
                        nil];
    [filter setDefaults];
    [filter setValue:[CIVector vectorWithX:180 Y:600] forKey:@"inputTopLeft"];
    [filter setValue:[CIVector vectorWithX:102 Y:20] forKey:@"inputBottomLeft"];
    
    CIImage *output = [filter valueForKey:kCIOutputImageKey];
    if (!output)
    {
        NSLog(@"Core Image processing error");
        return nil;
    }
    
    UIImage *results = [UIImage imageWithCIImage:output];
    return results;
}

- (UIImage *) pinchDistortionExample
{
    CIFilter *filter = [CIFilter filterWithName:@"CIPinchDistortion"
                                  keysAndValues: @"inputImage", self.coreImageRepresentation,
                        nil];
    [filter setDefaults];
    
    CIImage *output = [filter valueForKey:kCIOutputImageKey];
    if (!output)
    {
        NSLog(@"Core Image processing error");
        return nil;
    }
    
    UIImage *results = [UIImage imageWithCIImage:output];
    return results;
}

- (UIImage *) bloomExample
{
    CIFilter *filter = [CIFilter filterWithName:@"CIBloom"
                                  keysAndValues: @"inputImage", self.coreImageRepresentation,
                        nil];
    [filter setDefaults];
    
    CIImage *output = [filter valueForKey:kCIOutputImageKey];
    if (!output)
    {
        NSLog(@"Core Image processing error");
        return nil;
    }
    
    UIImage *results = [UIImage imageWithCIImage:output];
    return results;
}
@end
