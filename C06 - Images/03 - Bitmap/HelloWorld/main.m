/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIImage-Utils.h"
#import "Utility.h"

#define IMAGE_ARRAY @[@"359.jpg", @"360.jpg", @"361.jpg", @"365.jpg", @"366.jpg"]

@interface TouchView : UIImageView
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic) NSData *imageData;
@end

@implementation TouchView
- (void) handle: (CGPoint) aPoint
{
    // Set origin to the center of the view
    aPoint.x -= self.center.x;
    aPoint.y -= self.center.y;

    // Calculate the point in the image's view coordinate system
    CGFloat imageWidth = self.image.size.width;
    CGFloat imageHeight = self.image.size.height;
    CGFloat xScale = imageWidth / self.frame.size.width;
    CGFloat yScale = imageHeight / self.frame.size.height;
    CGFloat scale = MIN(xScale, yScale);
    CGAffineTransform t = CGAffineTransformMakeScale(scale, scale);
    CGPoint adjustedPoint = CGPointApplyAffineTransform(aPoint, t);
    
    // Reset the origin to the top-left corner of the image
    adjustedPoint.x += imageWidth / 2.0f;
    adjustedPoint.y += imageHeight / 2.0f;

    // Refresh the image data if needed (it shouldn't be needed)
    if (!_imageData)
        _imageData = self.image.bytes;
    
    // Retrieve the byte values at the given point -- these are cast to unsigned int, so floor values
    Byte *bytes = (Byte *)_imageData.bytes;
    CGFloat red = bytes[redOffset(adjustedPoint.x, adjustedPoint.y, imageWidth)] / 255.0f;
    CGFloat green = bytes[greenOffset(adjustedPoint.x, adjustedPoint.y, imageWidth)] / 255.0f;
    CGFloat blue = bytes[blueOffset(adjustedPoint.x, adjustedPoint.y, imageWidth)] / 255.0f;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];

    // Update the nav bar to match the color at the user's touch
    _controller.navigationController.navigationBar.tintColor = color;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    [self handle:location];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    [self handle:location];
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    TouchView *imageView;
    UISegmentedControl *seg;
}

// Refresh the image
- (void) updateImage
{
    imageView.image = [UIImage imageNamed:IMAGE_ARRAY[seg.selectedSegmentIndex]];
    imageView.imageData = imageView.image.bytes;
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
    imageView = [[TouchView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.controller = self;
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    STRETCH_VIEW(self.view, imageView);
    
    // User options for operation
    self.navigationItem.leftBarButtonItems = @[
    ];
    
    // Present a variety of image items
    NSArray *items = @[@"A", @"B", @"C", @"D", @"E"];
    seg = [[UISegmentedControl alloc] initWithItems:items];
    seg.frame = CGRectMake(0.0f, 0.0f, 0.0f, 22.0f);
    seg.selectedSegmentIndex = 0;
    seg.segmentedControlStyle = UISegmentedControlStyleBar;
    self.navigationItem.titleView = seg;
    
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