/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIBezierPath-Points.h"

#define POINTSTRING(_CGPOINT_) (NSStringFromCGPoint(_CGPOINT_))
#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

// Return dot product of two vectors normalized
static float dotproduct (CGPoint v1, CGPoint v2)
{
	float dot = (v1.x * v2.x) + (v1.y * v2.y);
	float a = ABS(sqrt(v1.x * v1.x + v1.y * v1.y));
	float b = ABS(sqrt(v2.x * v2.x + v2.y * v2.y));
	dot /= (a * b);
	
	return dot;
}

// Pass a tolerance within 0 to 1. 0 tolerance uses the tightest checking for colinearity
// As the values loosen, colinearity will be allowed for angles further from 180 degrees
UIBezierPath *thinPath(UIBezierPath *path, CGFloat tolerance)
{
    NSArray *points = path.points;
    if (points.count < 3) return path;
    
    UIBezierPath *newPath = [UIBezierPath bezierPath];
    CGPoint p1 = POINT(0);
    [newPath moveToPoint:p1];
    
    CGPoint mostRecent = p1;
    int count = 1;
    
    // -0.985 = 170 degrees. -0.865 = 150 degrees
    CGFloat checkValue = -1.0f + .135 * tolerance;
	
	// Add only those points that are inflections
	for (int i = 1; i < (points.count - 1); i++)
	{
		CGPoint p2 = POINT(i);
		CGPoint p3 = POINT(i+1);
		
		// Cast vectors around p2 origin
		CGPoint v1 = CGPointMake(p1.x - p2.x, p1.y - p2.y);
		CGPoint v2 = CGPointMake(p3.x - p2.x, p3.y - p2.y);
		float dot = dotproduct(v1, v2);
        
		// Colinear items need to be as close as possible to 180 degrees
        // That means as close to -1 as possible
        
		if (dot < checkValue) continue;
		p1 = p2;
        
        mostRecent = POINT(i);
        [newPath addLineToPoint:mostRecent];
        count++;
	}
	
	// Add final point
    CGPoint finalPoint = POINT(points.count - 1);
    if (!CGPointEqualToPoint(finalPoint, mostRecent))
        [newPath addLineToPoint:finalPoint];
    
    return newPath;
}

