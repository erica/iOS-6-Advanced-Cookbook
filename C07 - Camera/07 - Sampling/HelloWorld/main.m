/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "CameraImageHelper.h"
#import "UIImage-Utils.h"
#import "Utility.h"
#import "Colors.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
    CameraImageHelper *helper;
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


CGRect CGRectCenteredInRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
	return CGRectOffset(rect, dx, dy);
}

#define SAMPLE_LENGTH	128

- (void) pickColor
{
    UIImage *currentImage = helper.currentImage;
    CGRect sampleRect = CGRectMake(0.0f, 0.0f, SAMPLE_LENGTH, SAMPLE_LENGTH);
    sampleRect = CGRectCenteredInRect(sampleRect, (CGRect){.size = currentImage.size});    
    UIImage *sampleImage = [currentImage subImageWithBounds:sampleRect];
    
    UIImageView *iv = (UIImageView *) self.navigationItem.titleView;
    iv.image = sampleImage;
    
    NSData *bitData = sampleImage.bytes;
    Byte *bits = (Byte *)bitData.bytes;

	int bucket[360];
	CGFloat sat[360], bri[360];
	
	// Initialize hue bucket and average saturation and brightness collectors
	for (int i = 0; i < 360; i++)
	{
		bucket[i] = 0;
		sat[i] = 0.0f;
		bri[i] = 0.0f;
	}

	// Iterate over each sample pixel, accumulating hsb info
	for (int y = 0; y < SAMPLE_LENGTH; y++)
		for (int x = 0; x < SAMPLE_LENGTH; x++)
		{
			CGFloat r = ((CGFloat)bits[redOffset(x, y, SAMPLE_LENGTH)] / 255.0f);
			CGFloat g = ((CGFloat)bits[greenOffset(x, y, SAMPLE_LENGTH)] / 255.0f);
			CGFloat b = ((CGFloat)bits[blueOffset(x, y, SAMPLE_LENGTH)] / 255.0f);
			
			CGFloat h, s, v;
			rgbtohsb(r, g, b, &h, &s, &v);
			int hue = (h > 359.0f) ? 0 : (int) h;
			bucket[hue]++;
			sat[hue] += s;
			bri[hue] += v;
		}
	
	// Retrieve the hue mode
	int max = -1;
	int maxVal = -1;
	for (int i = 0; i < 360; i++)
	{
		if (bucket[i]  > maxVal)
		{
			max = i;
			maxVal = bucket[i];
		}
	}
	
	// Create a color based on the mode hue, average sat & bri
	float h = max / 360.0f;
	float s = sat[max]/maxVal;
	float br = bri[max]/maxVal;
	
	UIColor *hueColor = [UIColor colorWithHue:h saturation:s brightness:br alpha:1.0f];
    self.navigationController.navigationBar.tintColor = hueColor;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    
    // Establish the preview session
    helper = [CameraImageHelper helperWithCamera:kCameraBack];
    [helper startRunningSession];
    [helper embedPreviewInView:imageView];
    [helper layoutPreviewInView:imageView];
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
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
    
    // Switch between cameras
    if ([CameraImageHelper numberOfCameras] > 1)
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Switch", @selector(switchCameras));
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(pickColor)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
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