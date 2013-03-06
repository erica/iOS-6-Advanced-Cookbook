/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-Transform.h"
#import "Utility.h"

@interface DragView : UIView
@end

@implementation DragView

- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
    if (uigr.state == UIGestureRecognizerStateEnded)
    {
        CGPoint newCenter = CGPointMake(
                                        self.center.x + self.transform.tx,
                                        self.center.y + self.transform.ty);
        self.center = newCenter;
        
        CGAffineTransform theTransform = self.transform;
        theTransform.tx = 0.0f;
        theTransform.ty = 0.0f;
        self.transform = theTransform;
        
        return;
    }
    
    CGPoint translation = [uigr translationInView:self.superview];
    CGAffineTransform theTransform = self.transform;
    theTransform.tx = translation.x;
    theTransform.ty = translation.y;
    self.transform = theTransform;
}

- (id) initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return self;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
    
    return self;
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    CGFloat theta;
    UIView *view1;
    UIView *view2;
}

- (void) action: (id) sender
{
    self.title = [view1 intersectsView:view2] ? @"Intersect" : @"Clear";
}

- (void) rotate
{
    theta = M_PI / 4.0f;
    view1.transform = CGAffineTransformRotate(view1.transform, theta);
}

- (void) setupRotateDemo
{
    
    view1 = [[DragView alloc] initWithFrame:CGRectMake(0, 0, 100,100)];
    view1.center = RECTCENTER(self.view.bounds);
    view1.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.75f];
    [self rotate];
    [self.view addSubview:view1];
    
    view2 = [[DragView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    view2.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.75f];
    view2.center = view1.transformedBottomLeft;
    [self.view addSubview:view2];
    
    // [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(rotate) userInfo:nil repeats:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setupRotateDemo];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
}
@end


#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end
@implementation TestBedAppDelegate
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