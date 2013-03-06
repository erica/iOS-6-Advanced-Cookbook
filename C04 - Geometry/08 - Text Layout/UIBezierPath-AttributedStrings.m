/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIBezierPath-AttributedStrings.h"
#import "UIBezierPath-Points.h"
#import "NSAttributedString-Rendered.h"

#define POINTSTRING(_CGPOINT_) (NSStringFromCGPoint(_CGPOINT_))
#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [((NSValue *)[points objectAtIndex:_INDEX_]) CGPointValue]

@implementation UIBezierPath (AttributedStrings)
- (void) drawAttributedString: (NSAttributedString *) string withOptions: (StringRenderingOptions) renderingOptions
{
    if (!string) return;
    
    NSArray *points = self.points;
	int pointCount = points.count;
	if (pointCount < 2) return;
    
    // Please do not send over anything with a new line
    NSAttributedString *baseString = string.versionWithoutNewLines;

	// Keep a running tab of how far the glyphs have travelled to
	// be able to calculate the percent along the point path
	float glyphDistance = 0.0f;
    
    // Should the renderer squeeze/stretch the text to fit?
    BOOL fitText = (renderingOptions & RenderStringToFit) != 0;
    float lineLength = fitText ? baseString.renderedWidth : self.length;
    
    // Optionally force close path
    BOOL closePath = (renderingOptions & RenderStringClosePath) != 0;
    if (closePath) [self addLineToPoint:POINT(0)];

    // Establish the context
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // Set the initial positions -- skip?
    CGPoint textPosition = CGPointMake(0.0f, 0.0f);
	CGContextSetTextPosition(context, textPosition.x, textPosition.y);
    
    for (int loc = 0; loc < baseString.length; loc++)
    {
        // Retrieve item
        NSRange range = NSMakeRange(loc, 1);
        NSAttributedString *item = [baseString attributedSubstringFromRange:range];
        
        // Calculate the percent travel
        CGFloat glyphWidth = item.renderedWidth;
        glyphDistance += glyphWidth;
        CGFloat percentConsumed = glyphDistance / lineLength;
        if (percentConsumed > 1.0f) break; // stop when all consumed
        
        // Find a corresponding pair of points in the path
        CGPoint slope;
        CGPoint targetPoint = [self pointAtPercent:percentConsumed withSlope:&slope];
        
        // Set the x and y offset
		CGContextTranslateCTM(context, targetPoint.x, targetPoint.y);
		CGPoint positionForThisGlyph = CGPointMake(textPosition.x, textPosition.y);
        
        // Rotate
        float angle = atan(slope.y / slope.x);
        if (slope.x < 0) angle += M_PI; // going left, update the angle
        CGContextRotateCTM(context, angle);
        
        // Place the glyph
        positionForThisGlyph.x -= glyphWidth;
        
        if ((renderingOptions & RenderStringOutsidePath) != 0)
        {
                positionForThisGlyph.y -= item.renderedHeight;
        }
        else if ((renderingOptions & RenderStringInsidePath) != 0)
        {
            // no op
        }
        else // over path or default
        {
                positionForThisGlyph.y -= item.renderedHeight / 2.0f;
        }
        
        // Draw the glyph
        [item drawAtPoint:positionForThisGlyph]; // was textPosition
        
        // Reset context transforms
		CGContextRotateCTM(context, -angle);
		CGContextTranslateCTM(context, -targetPoint.x, -targetPoint.y);
	}
    
	CGContextRestoreGState(context);
}
@end
