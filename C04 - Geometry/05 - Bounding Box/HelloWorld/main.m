/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

#import "UIBezierPath-Points.h"
#import "UIBezierPath-Bounding.h"

@interface BezierView : UIView
- (void) clear;
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

- (void) drawPath: (UIBezierPath *) aPath
{
    [[COOKBOOK_PURPLE_COLOR colorWithAlphaComponent:0.25f] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), aPath.bounds);
    [[UIColor darkGrayColor] set];
    [aPath stroke];
    [[UIColor blackColor] set];
    UIBezierPath *convex = aPath.convexHull;
    convex.lineWidth = 3.0f;
    [convex stroke];
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    for (UIBezierPath *path in paths)
        [self drawPath:path];
    for (UIBezierPath *path in [touchPaths allValues])
        [self drawPath:path];
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