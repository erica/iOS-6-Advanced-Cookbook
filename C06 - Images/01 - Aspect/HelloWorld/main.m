/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIImage-Aspect.h"
#import "Utility.h"

#define IMAGE_ARRAY @[@"359.jpg", @"360.jpg", @"361.jpg", @"365.jpg", @"366.jpg"]

typedef enum
{
    kFill,
    kFit,
    kCenter,
    kSqueeze
} imageOpType;

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    UISegmentedControl *seg;
    imageOpType mostRecentOp;
}

- (void) fill
{
    NSString *title = IMAGE_ARRAY[seg.selectedSegmentIndex];
    UIImage *image = [UIImage imageNamed:title];
    imageView.image = [image applyAspect:UIViewContentModeScaleAspectFill inRect:imageView.bounds];
    mostRecentOp = kFill;
}

- (void) fit
{
    NSString *title = IMAGE_ARRAY[seg.selectedSegmentIndex];
    UIImage *image = [UIImage imageNamed:title];
    imageView.image = [image applyAspect:UIViewContentModeScaleAspectFit inRect:imageView.bounds];
    mostRecentOp = kFit;
}

- (void) center
{
    NSString *title = IMAGE_ARRAY[seg.selectedSegmentIndex];
    UIImage *image = [UIImage imageNamed:title];
    imageView.image = [image applyAspect:UIViewContentModeCenter inRect:imageView.bounds];
    mostRecentOp = kCenter;
}

- (void) squeeze
{
    NSString *title = IMAGE_ARRAY[seg.selectedSegmentIndex];
    UIImage *image = [UIImage imageNamed:title];
    imageView.image = [image applyAspect:UIViewContentModeScaleToFill inRect:imageView.bounds];
    mostRecentOp = kSqueeze;
}

// Refresh the image
- (void) updateImage
{
    switch (mostRecentOp)
    {
        case kFill:
            [self fill];
            break;
        case kFit:
            [self fit];
            break;
        case kCenter:
            [self center];
            break;
        default:
            [self squeeze];
    }
}

// Present initial image
- (void) viewDidAppear:(BOOL)animated
{
    [self updateImage];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Add an image view to display
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    STRETCH_VIEW(self.view, imageView);
    
    // User options for operation
    self.navigationItem.leftBarButtonItems = @[
    BARBUTTON(@"fill", @selector(fill)),
    BARBUTTON(@"fit", @selector(fit)),
    BARBUTTON(@"cen", @selector(center)),
    BARBUTTON(@"sq", @selector(squeeze)),
    ];
    
    // Present a variety of image items
    NSArray *items = @[@"A", @"B", @"C", @"D", @"E"];
    seg = [[UISegmentedControl alloc] initWithItems:items];
    seg.frame = CGRectMake(0.0f, 0.0f, 0.0f, 22.0f);
    seg.selectedSegmentIndex = 0;
    seg.segmentedControlStyle = UISegmentedControlStyleBar;
    self.navigationItem.titleView = seg;
    
    // Squeeeeeeeze for iPhone to fit
    if (IS_IPHONE)
    {
        NSDictionary *attributeDictionary = @{UITextAttributeFont : [UIFont fontWithName:@"Futura" size:10.0f]};
        [seg setTitleTextAttributes:attributeDictionary forState:UIControlStateNormal];
    }
    
    // Update image on selection
    CALLBACK_VAL(seg, @selector(updateImage));
}

// Re-set segmented control height
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    seg.frame = CGRectMake(0.0f, 0.0f, 0.0f, 22.0f);
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