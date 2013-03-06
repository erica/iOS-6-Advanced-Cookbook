/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIImage-Aspect.h"
#import "Geometry-Aspect.h"

@implementation UIImage (Aspect)

// Commented portions prevent small art from being scaled up
// but do not affect large art from being fit or filled
- (UIImage *) applyAspect: (UIViewContentMode) mode inRect: (CGRect) bounds
{
    CGRect destRect;
    
	UIGraphicsBeginImageContext(bounds.size);
    switch (mode)
    {
        case UIViewContentModeScaleToFill:
        {
            destRect = bounds;
            break;
        }
        case UIViewContentModeScaleAspectFill:
        {
            // The commented version will not scale up, only down
            /*
            CGRect rect = (CGRect){.size = self.size};
            
            if ((self.size.width > bounds.size.width) ||
                (self.size.height > bounds.size.height))
                rect = CGRectAspectFillRect(self.size, bounds);
            
             */
            
            CGRect rect = CGRectAspectFillRect(self.size, bounds);
            destRect = CGRectCenteredInRect(rect, bounds);
            
            break;
        }
        case UIViewContentModeScaleAspectFit:
        {
            // The commented version will not scale up, only down
            /*
            CGRect rect = CGRectFitSizeInRect(self.size, bounds);
             */
            
            CGRect rect = CGRectAspectFitRect(self.size, bounds);
            destRect = CGRectCenteredInRect(rect, bounds);

            break;
        }
        case UIViewContentModeCenter:
        {
            CGRect rect = (CGRect){.size = self.size};
            destRect = CGRectCenteredInRect(rect, bounds);
            break;
        }
        default:
            break;
    }
    
    [self drawInRect:destRect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
