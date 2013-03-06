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
#import "exifGeometry.h"

#import "Utility.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    CameraImageHelper *helper;
    
    CIImage *ciImage;
    CADisplayLink *displayLink;
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

- (void) snap
{
    UIImageOrientation imageOrientation = currentImageOrientation(helper.isUsingFrontCamera, NO);
    
    ciImage = helper.ciImage;
    UIImage *baseImage = [UIImage imageWithCIImage:ciImage orientation:imageOrientation];
    CGRect imageRect = (CGRect){.size = baseImage.size};
    
    NSDictionary *detectorOptions = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    
    ExifOrientation detectOrientation = detectorEXIF(helper.isUsingFrontCamera, NO);
    NSLog(@"Current orientation: %@", exifOrientationNameFromOrientation(detectOrientation));
    
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:detectOrientation] forKey:CIDetectorImageOrientation];
    NSArray *features = [detector featuresInImage:ciImage options:imageOptions];
    
    UIGraphicsBeginImageContext(baseImage.size);
    [baseImage drawInRect:imageRect];
    
    for (CIFaceFeature *feature in features)
    {
        CGRect rect = rectInEXIF(detectOrientation, feature.bounds, imageRect);
        if (deviceIsPortrait() && helper.isUsingFrontCamera) // workaround
        {
            rect.origin = CGPointFlipHorizontal(rect.origin, imageRect);
            rect.origin = CGPointOffset(rect.origin, -rect.size.width, 0.0f);
        }
        
        [[[UIColor blackColor] colorWithAlphaComponent:0.3f] set];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        [path fill];
        
        if (feature.hasLeftEyePosition)
        {
            [[[UIColor redColor] colorWithAlphaComponent:0.5f] set];
            CGPoint position = feature.leftEyePosition;
            CGPoint pt = pointInEXIF(detectOrientation, position, imageRect);
            if (deviceIsPortrait() && helper.isUsingFrontCamera) // workaround
                pt = CGPointFlipHorizontal(pt, imageRect);
            
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:30.0f startAngle:0.0f endAngle:2 * M_PI clockwise:YES];
            [path fill];
        }
        
        if (feature.hasRightEyePosition)
        {
            [[[UIColor blueColor] colorWithAlphaComponent:0.5f] set];
            CGPoint position = feature.rightEyePosition;
            CGPoint pt = pointInEXIF(detectOrientation, position, imageRect);
            if (deviceIsPortrait() && helper.isUsingFrontCamera) // workaround
                pt = CGPointFlipHorizontal(pt, imageRect);
            
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:30.0f startAngle:0.0f endAngle:2 * M_PI clockwise:YES];
            [path fill];
        }
        
        if (feature.hasMouthPosition)
        {
            [[[UIColor greenColor] colorWithAlphaComponent:0.5f] set];
            CGPoint position = feature.mouthPosition;
            CGPoint pt = pointInEXIF(detectOrientation, position, imageRect);
            if (deviceIsPortrait() && helper.isUsingFrontCamera) // workaround
                pt = CGPointFlipHorizontal(pt, imageRect);
            
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:30.0f startAngle:0.0f endAngle:2 * M_PI clockwise:YES];
            [path fill];
        }
        
    }
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
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
       
    // Switch between cameras
    if ([CameraImageHelper numberOfCameras] > 1)
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Switch", @selector(switchCameras));
    
    // The image view holds the live preview
    imageView = [[UIImageView alloc] init];
    [self.view addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    STRETCH_VIEW(self.view, imageView);
    imageView.contentMode = UIViewContentModeCenter;
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