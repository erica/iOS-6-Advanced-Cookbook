/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>


typedef enum {
    RenderStringDefault = 0,
    RenderStringOverPath = 1 << 1, // default
    RenderStringOutsidePath = 1 << 2,
    RenderStringInsidePath = 1 << 3,
    RenderStringToFit = 1 << 4,
    RenderStringClosePath = 1 << 5,
} StringRenderingOptions;

@interface UIBezierPath (AttributedStrings)
- (void) drawAttributedString: (NSAttributedString *) string withOptions: (StringRenderingOptions) renderingOption;
@end
