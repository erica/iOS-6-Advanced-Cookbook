/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

#import "UIBezierPath-Points.h"

@interface BezierView : UIView
@end

@implementation BezierView
{
    NSMutableArray *paths;
    NSMutableDictionary *touchPaths;
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        self.multipleTouchEnabled = YES;
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!touchPaths)
        touchPaths = [NSMutableDictionary dictionary];
    
    for (UITouch *touch in touches)
    {
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint point = [touch locationInView:self];
        [path moveToPoint:point];
        
        touchPaths[@((int)touch)] = path;
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint point = [touch locationInView:self];
        NSNumber *key = @((int)touch);
        UIBezierPath *path = touchPaths[key];
        if (path)
            [path addLineToPoint:point];
    }
    
    [self setNeedsDisplay];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!paths)
        paths = [NSMutableArray array];
    
    for (UITouch *touch in touches)
    {
        CGPoint point = [touch locationInView:self];
        NSNumber *key = @((int)touch);
        UIBezierPath *path = touchPaths[key];
        if (path)
            [path addLineToPoint:point];
        
        [touchPaths removeObjectForKey:key];
        [paths addObject:path];
    }
    
    [self setNeedsDisplay];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void) clear
{
    paths = [NSMutableArray array];
    touchPaths = [NSMutableDictionary dictionary];
    [self setNeedsDisplay];
}

- (void) drawCircleAtPoint: (CGPoint) aPoint
{
    CGFloat radius = 2.0f;
    CGRect rect = CGRectMake(aPoint.x - radius, aPoint.y - radius, radius * 2, radius * 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [path stroke];
}

- (void) drawPath: (UIBezierPath *) aPath
{
    [aPath stroke];
    NSArray *points = aPath.points;
    for (NSValue *pointValue in points)
        [self drawCircleAtPoint:pointValue.CGPointValue];
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    for (UIBezierPath *path in paths)
        [self drawPath:path];
    for (UIBezierPath *path in [touchPaths allValues])
        [self drawPath:path];
    
    // Test paths
    CGRect inset = CGRectInset(self.frame, 32.0f, 32.0f);
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:inset];
    [self drawPath:ovalPath];
    
    UIBezierPath *rrPath = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:32.0f];
    [self drawPath:rrPath];    
    
    UIBezierPath *basePath = [UIBezierPath bezierPath];
    [basePath moveToPoint:self.center];
    [basePath addQuadCurveToPoint:CGPointMake(0.0f, 0.0f) controlPoint:CGPointMake(100.0f, 100.0f)];
    [basePath addCurveToPoint:CGPointMake(320.0f, 75.0f) controlPoint1:CGPointMake(100.0f, 100.0f) controlPoint2:CGPointMake(200.0f, 100.0f)];
    [self drawPath:basePath];
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) clear
{
    [(BezierView *)self.view clear];
}

- (void) loadView
{
    [super loadView];
    self.view = [[BezierView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Clear", @selector(clear));
}
@end

#pragma mark - Application Setup -
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end
@implementation TestBedAppDelegate
{
	UIWindow *window;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}