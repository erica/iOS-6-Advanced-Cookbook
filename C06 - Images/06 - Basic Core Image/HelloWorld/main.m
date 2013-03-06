/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage-CoreImage.h"
#import "Utility.h"

/*
 All images public domain
 Petr Kratochvil - Chapel
 Axel Kuhlmann - Hexenei
 Petr Kratochvil - Leaves
 Alice Birkin - Sheep
 */

#define IMAGE_ARRAY @[@"chapel.jpg", @"sheep.jpg", @"leaves.jpg", @"hexenei.jpg"]


@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    UISegmentedControl *seg;
    NSInteger action;
}

// Refresh the image
- (void) updateImage
{
    imageView.image = [UIImage imageNamed:IMAGE_ARRAY[seg.selectedSegmentIndex]];
}

#define ACTION_ARRAY @[@"Sepia", @"Persp", @"Pinch", @"Bloom"]

- (void) action
{
    UIImage *outputImage;
    switch (action)
    {
        case 0:
             outputImage = [imageView.image sepiaVersion:0.75f];
            break;
        case 1:
            outputImage = [imageView.image perspectiveExample];
            break;
        case 2:
            outputImage = [imageView.image pinchDistortionExample];
            break;
        case 3:
            outputImage = [imageView.image bloomExample];
            break;
        default:
            break;
    }
    imageView.image = outputImage;
}

- (void) switchAction
{
    action = (action + 1) % ACTION_ARRAY.count;
    self.navigationItem.leftBarButtonItem.title = ACTION_ARRAY[action];
}

- (void) listFilters
{
    NSArray *categories = @[kCICategoryDistortionEffect,
    kCICategoryGeometryAdjustment,
    kCICategoryCompositeOperation,
    kCICategoryHalftoneEffect,
    kCICategoryColorAdjustment,
    kCICategoryColorEffect,
    kCICategoryTransition,
    kCICategoryTileEffect,
    kCICategoryGenerator,
    kCICategoryReduction,
    kCICategoryGradient,
    kCICategoryStylize,
    kCICategorySharpen,
    kCICategoryBlur,
    kCICategoryVideo,
    kCICategoryStillImage,
    kCICategoryInterlaced,
    kCICategoryNonSquarePixels,
    kCICategoryHighDynamicRange ,
    kCICategoryBuiltIn,];
    
    for (NSString *cat in categories)
    {
        NSString *category = cat;
        NSRange range = [category rangeOfString:@"CICategory"];
        if (range.location != NSNotFound)
            category = [category substringFromIndex:range.length];
        printf("\n%s\n", category.UTF8String);
        for (NSString *filterName in [CIFilter filterNamesInCategory:cat])
            printf("  - %s\n", filterName.UTF8String);
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
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    STRETCH_VIEW(self.view, imageView);
    
    // User options for operation
    self.navigationItem.leftBarButtonItems = @[
    BARBUTTON(ACTION_ARRAY[0], @selector(action)),
    BARBUTTON(@"Switch", @selector(switchAction)),
    ];
    
    self.navigationItem.rightBarButtonItems = @[
    BARBUTTON(@"Reset", @selector(updateImage)),
    BARBUTTON(@"List", @selector(listFilters)),
    ];
    
    // Present a variety of image items
    NSArray *items = @[@"A", @"B", @"C", @"D"];
    seg = [[UISegmentedControl alloc] initWithItems:items];
    seg.frame = CGRectMake(0.0f, 0.0f, 0.0f, 32.0f);
    seg.selectedSegmentIndex = 0;
    seg.segmentedControlStyle = UISegmentedControlStyleBar;
    self.navigationItem.titleView = seg;
    
    // Update image on selection
    CALLBACK_VAL(seg, @selector(updateImage));
}

// Re-set segmented control height
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    seg.frame = CGRectMake(0.0f, 0.0f, 0.0f, 32.0f);
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