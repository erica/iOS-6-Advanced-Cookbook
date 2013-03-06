/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "FancyString.h"
#import "Utility.h"

@interface CTView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, strong) NSAttributedString *attributedString;
@end

@implementation CTView
- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        self.delegate = self;
    }
    return self;
}

// Calculates the content size
- (void) updateContentSize
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
	CFRange destRange = CFRangeMake(0, 0);
    CFRange sourceRange = CFRangeMake(0, _attributedString.length);
	CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, sourceRange, NULL, CGSizeMake(self.frame.size.width, CGFLOAT_MAX), &destRange);
	self.contentSize = CGSizeMake(self.bounds.size.width, frameSize.height);
    CFRelease(framesetter);
}

// This is a scroll-view specific drawRect
- (void) drawRect:(CGRect)rect
{
	[super drawRect: rect];
	CGContextRef context = UIGraphicsGetCurrentContext();

    // Flip the context
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.contentSize.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGMutablePathRef path = CGPathCreateMutable();
    CGRect destRect = (CGRect){.size = self.contentSize};
	CGPathAddRect(path, NULL, destRect);

    // Create framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);

	// Draw the text
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _attributedString.length), path, NULL);
	CTFrameDraw(theFrame, context);
	
    // Clean up
	CFRelease(path);
	CFRelease(theFrame);
    CFRelease(framesetter);
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
    
    UIFont *headerFont = [UIFont fontWithName:@"Futura" size:24.0f];
    UIFont *familyFont = [UIFont fontWithName:@"Futura" size:18.0f];
    
    string.paragraphStyle.firstLineHeadIndent = 20.0f;
    string.paragraphStyle.headIndent = 50.0f;
    string.paragraphStyle.tailIndent = -20.0f;
    
    for (NSString *familyName in [UIFont familyNames])
    {
        string.font = headerFont;
        string.foregroundColor = [UIColor redColor];
        [string appendFormat:@"\u25BC  %@\n", familyName];

        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName])
        {
            string.font = familyFont;
            string.foregroundColor = nil;
            [string appendFormat:@"\t\u25A0 %@:  ", fontName];
            string.font = [UIFont fontWithName:fontName size:18.0f];
            string.foregroundColor = [UIColor darkGrayColor];
            [string appendFormat:@"The Quick Brown Fox Jumps Over the Lazy Dog.\n"];
        }
        
        [string appendFormat:@"\n"];
    }
    
    ctView = [[CTView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:ctView];    
    PREPCONSTRAINTS(ctView);
    STRETCH_VIEW(self.view, ctView);
    
    ctView.attributedString = string.string;
}

- (void) viewDidAppear:(BOOL)animated
{
    [ctView updateContentSize];
    [ctView setNeedsDisplay];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [ctView updateContentSize];
    [ctView setNeedsDisplay];
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