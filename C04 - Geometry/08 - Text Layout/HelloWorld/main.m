/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

#import "UIBezierPath-AttributedStrings.h"

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

- (NSAttributedString *) lorem
{
    NSString *loremString = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent venenatis, enim ac accumsan porttitor, mi sapien viverra est, nec tempor tortor nulla iaculis sapien. Aliquam eget libero nibh, id fermentum nulla. Quisque auctor adipiscing justo sed convallis. Aliquam erat volutpat. Mauris dignissim pharetra diam id tincidunt.";
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:loremString];
    NSRange range = NSMakeRange(0, loremString.length);
    [attr addAttribute:NSForegroundColorAttributeName value:COOKBOOK_PURPLE_COLOR range:range];
    [attr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Futura" size:14.0f] range:range];
    
    return attr;
}

- (void) drawPath: (UIBezierPath *) aPath
{
    [aPath stroke];
    [aPath drawAttributedString:[self lorem] withOptions: RenderStringOutsidePath];
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