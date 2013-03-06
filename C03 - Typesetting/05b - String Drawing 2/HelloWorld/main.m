/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "FancyString.h"
#import "Utility.h"

@interface CTView : UIView
@property (nonatomic, strong) NSAttributedString *attributedString;
@end

@implementation CTView

- (id) initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return self;
	self.backgroundColor = [UIColor clearColor];
    return self;
}

- (void) drawRect:(CGRect)rect
{
	[super drawRect: rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    // Flip the context
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Slightly inset from the edges of the view
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect insetRect = CGRectInset(self.frame, 20.0f, 20.0f);
	CGPathAddRect(path, NULL, insetRect);
    // CGPathAddEllipseInRect(path, NULL, insetRect);
    
    // Build the framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);

	// Draw the text
	CTFrameRef destFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _attributedString.length), path, NULL);
	CTFrameDraw(destFrame, context);
	
    // Clean up
    CFRelease(framesetter);
	CFRelease(path);
	CFRelease(destFrame);
}
@end

@interface TestBedViewController : UIViewController
{
    CTView *ctView;
    FancyString *string;
}
@end

@implementation TestBedViewController
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];

    string = [FancyString string];
    
    // UIFont *headerFont = [UIFont fontWithName:@"Futura" size:36.0f];
    UIFont *baseFont = [UIFont fontWithName:@"Futura" size:18.0f];
    string.font = baseFont;
    
    // string.paragraphStyle.firstLineHeadIndent = 10.0f;
    // string.paragraphStyle.headIndent = 10.0f;
    // string.paragraphStyle.tailIndent = -10.0f;
    [string setAlignment:@"justified"];
    [string setBreakMode:@"word"];
    
    /* [string performTransientAttributeBlock:^(){
        string.font = headerFont;
        string.bold = YES;
        string.foregroundColor = [UIColor redColor];
        [string appendFormat:@"Hello World!\n"];
    }]; */
    
    [string appendFormat:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec et diam lacus. Mauris elit urna, cursus ut tristique eu, suscipit quis odio. Suspendisse ullamcorper dui ut elit blandit vulputate ornare nulla scelerisque. Proin molestie sollicitudin ultricies.Sed lobortis, felis imperdiet tincidunt elementum, odio diam egestas massa, id tempor sem nisl id enim. Etiam pretium, eros vitae malesuada sagittis, metus nisi aliquam sem, id euismod neque arcu at erat. Aenean sit amet magna nec sapien sodales laoreet at sit amet dui."];    
    
    ctView = [[CTView alloc] init];
    [self.view addSubview:ctView];
    PREPCONSTRAINTS(ctView);
    STRETCH_VIEW(self.view, ctView);

    ctView.attributedString = string.string;
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