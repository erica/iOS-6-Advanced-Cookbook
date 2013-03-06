/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

#import "UIBezierPath-Fitting.h"
#import "UIBezierPath-Bounding.h"
#import "UIBezierPath-Points.h"

CGPoint randomPointInRect(CGRect rect)
{
    CGPoint origin = rect.origin;
    
    CGFloat xOffset = (rand() % ((int)rect.size.width * 100)) / 100.0f;
    CGFloat yOffset = (rand() % ((int)rect.size.height * 100)) / 100.0f;
    
    origin.x += xOffset;
    origin.y += yOffset;
    
    return origin;
}

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
    [[COOKBOOK_PURPLE_COLOR colorWithAlphaComponent:0.4f] set];
    [aPath stroke];
    
    CGRect destRect = CGRectMake(200.0f, 200.0f, 100.0f, 100.0f);
    [[UIColor blackColor] set];
    UIBezierPath *smallPath = [aPath fitInRect:destRect];
    [smallPath stroke];
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [[COOKBOOK_PURPLE_COLOR colorWithAlphaComponent:0.4f] set];
    CGRect destRect = CGRectMake(200.0f, 200.0f, 100.0f, 100.0f);
    CGContextFillRect(UIGraphicsGetCurrentContext(), destRect);
    
    for (UIBezierPath *path in paths)
        [self drawPath:path];
    for (UIBezierPath *path in [touchPaths allValues])
        [self drawPath:path];
    
    [[UIColor blackColor] set];
    
    // Show how to adjust element-based path
    /*
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 140.0, 10.0f) cornerRadius:32.0f];
    UIBezierPath *test = [UIBezierPath bezierPath];
    [test moveToPoint:randomPointInRect(self.bounds)];
    
    for (int i = 0; i < 4; i++)
        [test addCurveToPoint:randomPointInRect(self.bounds) controlPoint1:randomPointInRect(self.bounds) controlPoint2:randomPointInRect(self.bounds)];
    
    [path appendPath:test];
    [path stroke];
    UIBezierPath *smallPath = [path fitElementsInRect:destRect];
    [smallPath stroke];
     */
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