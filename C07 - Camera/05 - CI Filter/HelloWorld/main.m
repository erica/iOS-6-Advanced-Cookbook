/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

#import "CameraImageHelper.h"
#import "UIImage-CoreImage.h"
#import "Orientation.h"

#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    CameraImageHelper *helper;
    CADisplayLink *displayLink;
    
    BOOL useFilter;
}

// Start or Pause
- (void) toggleSession
{
    if (helper.session.isRunning)
    {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Resume", @selector(toggleSession));
        [helper stopRunningSession];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pause", @selector(toggleSession));
        [helper startRunningSession];
    }
}

// Switch between cameras
- (void) switchCameras
{
    // Always reactivate, so the switch is live
    if (!helper.session.isRunning)
        [self toggleSession];
    
    // Perform the switch
    [helper switchCameras];
}

// Filter toggle
- (void) toggleFilter
{
    useFilter = !useFilter;
}

- (void) snap
{
    UIImageOrientation orientation = currentImageOrientation(helper.isUsingFrontCamera, NO);
    if (useFilter) // monochrome - red
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
        [filter setValue:helper.ciImage forKey:@"inputImage"];
        [filter setDefaults];
        [filter setValue:@1 forKey:@"inputIntensity"];
        [filter setValue:[CIColor colorWithRed:1.0f green:0.0f blue:0.0f] forKey:@"inputColor"];
        CIImage *outputImage = [filter valueForKey:kCIOutputImageKey];
        
        if (outputImage)
            imageView.image = [UIImage imageWithCIImage:outputImage orientation:orientation];
        else NSLog(@"Missing image");
    }
    
    
    if (!useFilter) // no filter
    {
        imageView.image = [UIImage imageWithCIImage:helper.ciImage orientation:orientation];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    
    // Establish the preview session
    helper = [CameraImageHelper helperWithCamera:kCameraBack];
    [helper startRunningSession];
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(snap)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.view layoutIfNeeded];
    [helper layoutPreviewInView:imageView];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Start or Pause
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pause", @selector(toggleSession));
    
    // Filter or not
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Toggle", @selector(toggleFilter));
    
    // The image view holds the live preview
    imageView = [[UIImageView alloc] init];
    [self.view addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    STRETCH_VIEW(self.view, imageView);
    imageView.contentMode = UIViewContentModeCenter;
}

// Other filters -- swap in if desired
- (void) otherFilters
{
    UIImageOrientation orientation = currentImageOrientation(helper.isUsingFrontCamera, NO);
    if (useFilter) // sepia
    {
        CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
        [filter setValue:helper.ciImage forKey:@"inputImage"];
        [filter setDefaults];
        [filter setValue:[NSNumber numberWithFloat:0.75f] forKey:@"inputIntensity"];
        CIImage *outputImage = [filter valueForKey:kCIOutputImageKey];
        
        if (outputImage)
            imageView.image = [UIImage imageWithCIImage:outputImage orientation:orientation];
        else NSLog(@"Missing image");
    }
    
    if (useFilter) // bloom
    {
        CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
        [filter setValue:helper.ciImage forKey:@"inputImage"];
        [filter setDefaults];
        CIImage *outputImage = [filter valueForKey:kCIOutputImageKey];
        
        if (outputImage)
            imageView.image = [UIImage imageWithCIImage:outputImage orientation:orientation];
        else NSLog(@"Missing image");
    }
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