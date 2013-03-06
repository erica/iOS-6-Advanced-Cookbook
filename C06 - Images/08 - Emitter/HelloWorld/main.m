/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>

@interface SparkleTouchView : UIView
@end

@implementation SparkleTouchView
{
    CAEmitterLayer *emitter;
}

- (id) initWithFrame: (CGRect) aFrame
{
    if (!(self = [super initWithFrame:aFrame])) return self;
    
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    float multiplier = 0.25f;
    
    CGPoint pt = [[touches anyObject] locationInView:self];
    
    //Create the emitter layer
    emitter = [CAEmitterLayer layer];
    emitter.emitterPosition = pt;
    emitter.emitterMode = kCAEmitterLayerOutline;
    emitter.emitterShape = kCAEmitterLayerCircle;
    emitter.renderMode = kCAEmitterLayerAdditive;
    emitter.emitterSize = CGSizeMake(100 * multiplier, 0);
    
    //Create the emitter cell
    CAEmitterCell* particle = [CAEmitterCell emitterCell];
    particle.emissionLongitude = M_PI;
    particle.birthRate = multiplier * 1000.0;
    particle.lifetime = multiplier;
    particle.lifetimeRange = multiplier * 0.35;
    particle.velocity = 180;
    particle.velocityRange = 130;
    particle.emissionRange = 1.1;
    particle.scaleSpeed = 1.0; // was 0.3
    particle.color = [[COOKBOOK_PURPLE_COLOR colorWithAlphaComponent:0.5f] CGColor];
    particle.contents = (__bridge id)([UIImage imageNamed:@"spark.png"].CGImage);
    particle.name = @"particle";
    
    emitter.emitterCells = [NSArray arrayWithObject:particle];
    [self.layer addSublayer:emitter];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self];
    
    // Disable implicit animations
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    emitter.emitterPosition = pt;
    [CATransaction commit];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [emitter removeFromSuperlayer];
    emitter = nil;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) loadView
{
    [super loadView];
    self.view = [[SparkleTouchView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
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