/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIBezierPath-Fitting.h"
#import "UIBezierPath-Bounding.h"

#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

CGFloat AspectScaleFit(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
	CGFloat scaleH = destSize.height / sourceSize.height;
    return MIN(scaleW, scaleH);
}

CGRect AspectFitRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGFloat destScale = AspectScaleFit(sourceSize, destRect);
	
	CGFloat newWidth = sourceSize.width * destScale;
	CGFloat newHeight = sourceSize.height * destScale;
	
	float dWidth = ((destSize.width - newWidth) / 2.0f);
	float dHeight = ((destSize.height - newHeight) / 2.0f);
	
	CGRect rect = CGRectMake(destRect.origin.x + dWidth, destRect.origin.y + dHeight, newWidth, newHeight);
	return rect;
}

CGPoint PointAddPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGPoint PointSubtractPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}


@implementation UIBezierPath (Fitting)

NSValue *adjustPoint(CGPoint p, CGRect native, CGRect dest)
{
    CGFloat scaleX = dest.size.width / native.size.width;
    CGFloat scaleY = dest.size.height / native.size.height;
    
    CGPoint point = PointSubtractPoint(p, native.origin);
    point.x *= scaleX;
    point.y *= scaleY;
    CGPoint destPoint = PointAddPoint(point, dest.origin);

    return [NSValue valueWithCGPoint:destPoint];
}

- (UIBezierPath *) fitInRect: (CGRect) destRect
{
    NSArray *points = self.points;
    CGRect bounding = self.bounds;
    
    CGRect fitRect = AspectFitRect(bounding.size, destRect);

    NSMutableArray *adjustedPoints = [NSMutableArray array];
    
    for (int i = 0; i < points.count; i++)
        [adjustedPoints addObject:adjustPoint(POINT(i), bounding, fitRect)];

    return [UIBezierPath pathWithPoints:adjustedPoints];
}

- (UIBezierPath *) fitElementsInRect: (CGRect) destRect
{
    CGRect bounding = self.bounds;
    CGRect fitRect = AspectFitRect(bounding.size, destRect);
    
    NSArray *elements = self.bezierElements;
    NSMutableArray *adjustedElements = [NSMutableArray array];
    for (NSArray *points in elements)
    {
        if (!points.count) continue;        
        NSMutableArray *outArray = [NSMutableArray array];
        [outArray addObject:points[0]]; // NSNumber, type
        for (int i = 1; i < points.count; i++)
            [outArray addObject:adjustPoint(POINT(i), bounding, fitRect)];
        [adjustedElements addObject:outArray];
    }

    return [UIBezierPath pathWithElements:adjustedElements];
}
@end
