/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIBezierPath-Bounding.h"

#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

@implementation UIBezierPath (Bounding)
static CGRect pointRect(CGPoint point)
{
    return (CGRect){.origin=point};
}

- (NSArray *) sortedPoints
{
    NSArray *sorted = [self.points sortedArrayUsingComparator:^NSComparisonResult(id item1, id item2)
    {
        NSValue *v1 = (NSValue *) item1;
        NSValue *v2 = (NSValue *) item2;
        
        CGPoint p1 = v1.CGPointValue;
        CGPoint p2 = v2.CGPointValue;
        
        if (p1.x == p2.x)
            return [@(p1.y) compare:@(p2.y)];
        else
            return [@(p1.x) compare:@(p2.x)];
    }];
    return sorted;
}

static float halfPlane(CGPoint p1, CGPoint p2, CGPoint testPoint)
{
    return (p2.x-p1.x)*(testPoint.y-p1.y) - (testPoint.x-p1.x)*(p2.y-p1.y);
}

- (UIBezierPath *) convexHull
{
    /*
     minmin = top left, min x, min y
     minmax = bottom left, min x, max y
     maxmin = top right, max x, min y
     maxmax = bottom right, max x, max y
     */
    
    NSMutableArray *output = [NSMutableArray array];
    NSInteger bottom = 0;
    NSInteger top = -1;
    NSInteger i;
    
    NSArray *points = self.sortedPoints;
    NSInteger lastIndex = points.count - 1;    
    NSInteger minmin = 0; 
    CGFloat xmin = POINT(0).x;

    // Locate minmax, bottom left
    for (i = 1; i <= lastIndex; i++)
        if (POINT(i).x != xmin)
            break;
    NSInteger minmax = i - 1;
    
    // If the bottom left is the final item
    // check whether to add both minmin & minmax
    if (minmax == lastIndex)
    {
        output[++top] = points[minmin];
        if (POINT(minmax).y != POINT(minmin).y)
        {
            // add the second point, and close the path
            output[++top] = points[minmax];
            output[++top] = points[minmin];
        }

        for (int i = top + 1; i < output.count; i++)
            [output removeObjectAtIndex:i];
        
        return [UIBezierPath pathWithPoints:output];
    }

    // Search for top right, max x, min y by moving
    // back from max x, max y at final index
    NSInteger maxmin = lastIndex;
    CGFloat xmax = POINT(lastIndex).x;
    for (i = lastIndex - 1; i >= 0; i--)
        if (POINT(i).x != xmax)
            break;
    maxmin = i + 1;

    // Compute Lower Hull
    output[++top] = points[minmin]; // top left
    i = minmax; // bottom left

    while (++i < maxmin) // top right
    {
        // Test against TopLeft-TopRight
        if ((halfPlane(POINT(minmin), POINT(maxmin), POINT(i)) >= 0) &&
            (i < maxmin))
            continue;
        
        while (top > 0)
        {
            if (halfPlane([output[top - 1] CGPointValue], [output[top] CGPointValue], POINT(i)) > 0)
                break;
            else
                top--;
        }
        output[++top] = points[i];
    }

    // Ensure the hull is continuous when going from lower to upper
    NSInteger maxmax = lastIndex;
    if (maxmax != maxmin)
        output[++top] = points[maxmax];

    // Compute Upper Hull
    bottom = top;
    i = maxmin;
    while (--i >= minmax)
    {
        if ((halfPlane(POINT(maxmax), POINT(minmax), POINT(i)) >= 0) &&
            (i > minmax))
            continue;
        
        while (top > bottom)
        {
            if (halfPlane([output[top - 1] CGPointValue], [output[top] CGPointValue], POINT(i)) > 0)
                break;
            else
                top--;
        }
        output[++top] = points[i];
    }
    
    // Again ensure continuity at the end
    if (minmax != minmin)
        output[++top] = points[minmin];
    
    NSMutableArray *results = [NSMutableArray array];
    for (int i = 0; i <= top; i++)
        [results addObject:output[i]];

    return [UIBezierPath pathWithPoints:results];
}
@end
