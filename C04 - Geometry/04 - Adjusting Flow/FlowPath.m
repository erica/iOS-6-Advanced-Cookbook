/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "FlowPath.h"
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]
#define DATE(_INDEX_) [(NSDate *)[dates objectAtIndex:_INDEX_] timeIntervalSinceReferenceDate]

static CGFloat distance(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p2.x - p1.x;
    CGFloat dy = p2.y - p1.y;
    
    return sqrt(dx * dx + dy * dy);
}

@implementation FlowPath
{
    NSMutableArray *points;
    NSMutableArray *dates;
}

+ (id) path
{
    return [[FlowPath alloc] init];
}

- (id) init
{
    if (self = [super init])
        _lineWidth = 1.0f;
    return self;
}

- (void) addPoint: (CGPoint) aPoint
{
    if (!points)
    {
        points = [NSMutableArray array];
        dates = [NSMutableArray array];
    }
    
    [points addObject:[NSValue valueWithCGPoint:aPoint]];
    [dates addObject:[NSDate date]];
}

- (UIBezierPath *) bezierPath
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (!points.count) return path;
    [path moveToPoint:POINT(0)];
    for (int i = 1; i < points.count; i++)
        [path addLineToPoint:POINT(i)];
    return path;
}

#pragma mark - stroking

- (CGFloat) velocityFrom:(int) j to:(int) i
{
    CGFloat dPos = distance(POINT(j), POINT(i));
    CGFloat dTime = (DATE(j) - DATE(i));
    return dPos / dTime;
}


- (CGFloat) strokeWidth: (CGFloat) velocity
{
    CGFloat multiplier = 2.0f;
    CGFloat base = 5.0f;
    CGFloat adjusted = base - (log2f(velocity) / multiplier);
    adjusted = MIN(MAX(adjusted, 0.4), base);
    return multiplier * adjusted * _lineWidth;
}

UIBezierPath *bPath(CGPoint p0, CGPoint p1)
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:p0];
    [path addLineToPoint:p1];
    return path;
}

- (void) stroke
{
    if (points.count < 2) return;

    CGFloat lastVelocity = [self velocityFrom:1 to:0];
    CGFloat weight = 0.5f;
    
    UIBezierPath *path;
    for (int i = 1; i < points.count; i++)
    {
        CGFloat velocity = [self velocityFrom:i to:i-1];
        velocity = weight * velocity + (1.0f - weight) * lastVelocity;
        lastVelocity = velocity;
        CGFloat strokeWidth = [self strokeWidth:velocity];

        path = bPath(POINT(i - 1), POINT(i));
        path.lineWidth = strokeWidth;
        [path stroke];
    }
}
@end
