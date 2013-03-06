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
    
    UIView *object;
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.multipleTouchEnabled = NO;
        object = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 20.0f)];
        object.backgroundColor = COOKBOOK_PURPLE_COLOR;
        object.alpha = 0.0f;
        [self addSubview:object];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!touchPaths)
        touchPaths = [NSMutableDictionary dictionary];
    [paths removeAllObjects];
    [self setNeedsDisplay];
    
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

- (void) animatePath: (UIBezierPath *) aPath withProgress: (CGFloat) progress
{
    object.alpha = 1.0f;
    
    if (progress > 1.0f)
    {
        [UIView animateWithDuration:0.3f animations:^(){object.alpha = 0.0f;}];
        self.userInteractionEnabled = YES;
        return;
    }
    
    [UIView animateWithDuration:0.1f animations:^(){
        CGPoint slope;
        CGPoint point = [aPath pointAtPercent:progress withSlope:&slope];
        object.center = point;
        object.transform = CGAffineTransformMakeRotation(atan2f(slope.y, slope.x));
    } completion:^(BOOL done){
        [self animatePath:aPath withProgress:progress + 0.025f];
    }];    
}

- (void) drawPath: (UIBezierPath *) aPath
{
    self.userInteractionEnabled = NO;
    [aPath stroke];
    [self animatePath:aPath withProgress:0.0f];
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    for (UIBezierPath *path in [touchPaths allValues])
        [path stroke];

    for (UIBezierPath *path in paths)
        [self drawPath:path];
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) loadView
{
    [super loadView];
    self.view = [[BezierView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
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