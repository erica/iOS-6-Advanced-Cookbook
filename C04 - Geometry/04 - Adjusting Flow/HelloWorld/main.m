/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "FlowPath.h"
#import "Utility.h"

@interface DrawingView : UIView
- (void) clear;
@property (nonatomic) NSInteger mode;
@end

@implementation DrawingView
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
        FlowPath *path = [FlowPath path];
        CGPoint point = [touch locationInView:self];
        [path addPoint:point];
        
        touchPaths[@((int)touch)] = path;
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint point = [touch locationInView:self];
        NSNumber *key = @((int)touch);
        FlowPath *path = touchPaths[key];
        if (path)
            [path addPoint:point];
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
        FlowPath *path = touchPaths[key];
        if (path)
            [path addPoint:point];
        
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

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];

    for (FlowPath *path in paths)
    {
        if (_mode == 1)
            [path stroke];
        else
            [path.bezierPath stroke];
    }
    
    for (FlowPath *path in [touchPaths allValues])
    {
        if (_mode == 1)
            [path stroke];
        else
            [path.bezierPath stroke];
    }
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) clear
{
    [(DrawingView *)self.view clear];
}

- (void) setMode: (UISegmentedControl *) seg;
{
    [(DrawingView *)self.view setMode:seg.selectedSegmentIndex];
    [self.view setNeedsDisplay];
}

- (void) loadView
{
    [super loadView];
    self.view = [[DrawingView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Clear", @selector(clear));
    
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[@"Orig", @"Proc"]];
    seg.selectedSegmentIndex = 1;
    [(DrawingView *)self.view setMode:1];
    CALLBACK_VAL(seg, @selector(setMode:));
    self.navigationItem.titleView = seg;
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