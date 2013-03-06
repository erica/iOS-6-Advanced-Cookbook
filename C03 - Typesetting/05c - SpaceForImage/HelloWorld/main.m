/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "Utility.h"
#import "FancyString.h"

#define LOREM @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tristique libero sed neque blandit blandit. Fusce ut velit nisl. Quisque at purus ante. Nunc pharetra risus at lectus imperdiet sollicitudin. Donec id mi sit amet turpis ultricies vulputate. Phasellus scelerisque turpis sed libero tincidunt faucibus nec ut massa. Suspendisse quam leo, eleifend eu ullamcorper vel, sodales quis eros. Nullam at dui accumsan libero tempus iaculis venenatis eget arcu. Nullam vestibulum tempor velit, in pulvinar lacus eleifend vel. Nunc ultrices adipiscing porttitor. Vivamus pretium orci ut lorem gravida eleifend.\n\nAenean ac tellus ut urna sagittis ornare. Sed varius auctor massa, id euismod lectus tempor in. Suspendisse nisi augue, fringilla non vestibulum ut, sodales ut magna. Phasellus sollicitudin egestas ullamcorper. Ut quam neque, euismod sed laoreet vel, pulvinar vitae sapien. Praesent ac hendrerit est. Proin sit amet sem urna, quis accumsan justo.\n\nIn hac habitasse platea dictumst. Donec lacinia, mauris nec tincidunt pellentesque, eros ligula bibendum risus, sed ullamcorper risus metus quis arcu. Proin libero nibh, blandit nec laoreet vel, elementum ut dui. Aenean rhoncus felis ut risus venenatis aliquam eu ultricies libero. Phasellus at orci dolor, vel porttitor eros. Nam sit amet quam eget metus laoreet convallis sollicitudin vitae magna. Nulla egestas, nibh non interdum vestibulum, nisi nibh fringilla nisl, non suscipit justo neque tempor arcu. Ut rutrum dui sit amet urna volutpat quis luctus neque venenatis. Aenean orci magna, sollicitudin ut luctus ut, aliquet dictum lacus. Donec gravida bibendum auctor.\n\nIn convallis turpis a quam suscipit ac malesuada justo consectetur. Suspendisse a hendrerit leo. Proin ultricies neque ullamcorper est vestibulum elementum. Curabitur quis massa risus. Nunc ac tellus quis metus ullamcorper malesuada. Vestibulum fermentum pretium fermentum. Pellentesque ut tortor nibh. Aliquam in elit tortor, eget euismod risus. Maecenas porttitor nisi aliquam mauris ultrices ultricies. Curabitur nibh quam, rutrum sit amet faucibus vitae, cursus viverra erat. Nunc neque est, vehicula id dignissim eu, placerat et leo. Morbi at lectus vitae odio auctor aliquam sed sit amet nulla. Etiam interdum mollis dui. Curabitur ullamcorper blandit consectetur.\n\nMaecenas dignissim aliquam velit, non facilisis sem vulputate eget. Vestibulum at nulla a orci condimentum ultrices. Integer vehicula varius pellentesque. Praesent elementum cursus leo at vestibulum. Vestibulum vestibulum augue vitae enim adipiscing interdum sed eu sem. Vivamus feugiat dapibus porta. Donec viverra eros rutrum diam ullamcorper tempus. Nullam libero odio, dapibus vel ultrices at, scelerisque eget leo. Integer porttitor convallis eros, ut dapibus enim luctus et."

@interface FooView : UIView
@end

@implementation FooView
- (NSAttributedString *) string
{
    FancyString *string = [FancyString string];
    string.font = [UIFont fontWithName:@"Futura" size:24.0f];
    string.foregroundColor = [UIColor redColor];
    [string setAlignment:@"Center"];
    
    [string appendFormat:@"Lorem Ispusm\n\n"];
    
    string.font = [UIFont fontWithName:@"Futura" size:18.0f];
    string.foregroundColor = [UIColor blackColor];
    [string setAlignment:@"left"];
    [string appendFormat:@"%@", LOREM];
    
    return string.string;
}

CGRect CGRectFlipVertical(CGRect innerRect, CGRect outerRect)
{
    CGRect rect = innerRect;
    rect.origin.y = outerRect.origin.y + outerRect.size.height - (rect.origin.y + rect.size.height);
    return rect;
}

- (void) drawRect: (CGRect) rect
{
    NSAttributedString *string = [self string];

    [super drawRect: rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect aRect = CGRectInset(self.bounds, 10.0f, 10.0f);
    
    // Draw the background
    [[UIColor whiteColor] set];
    CGContextFillRect(context, self.bounds);
    
    // Draw the Cover
    CGRect imageRect1 = CGRectMake(150.0f, 500.0f, 200.0f, 300.0f);
    [[UIImage imageNamed:@"Default.png"] drawInRect:CGRectInset(imageRect1, 10.0f, 10.0f)];
    
    // Draw the Bear (public domain)
    CGRect imageRect2 = CGRectMake(500.0f, 100.0f, 187.5f, 150.0f);
    [[UIImage imageNamed:@"Bear.jpg"] drawInRect:CGRectInset(imageRect2, 10.0f, 10.0f)];
	
    // Flip the context
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.frame.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
    // Start the path
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, aRect);
    
    // Cut out the image areas
    CGPathAddRect(path, NULL, CGRectFlipVertical(imageRect1, self.bounds));
    CGPathAddRect(path, NULL, CGRectFlipVertical(imageRect2, self.bounds));
    
    // Create framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
    
	// Draw the text
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, string.length), path, NULL);
	CTFrameDraw(theFrame, context);
    
    // Clean up
	CFRelease(path);
	CFRelease(theFrame);
    CFRelease(framesetter);

}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    FooView *view = [[FooView alloc] init];
    [self.view addSubview:view];
    
    PREPCONSTRAINTS(view);
    STRETCH_VIEW(self.view, view);
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