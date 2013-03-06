/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

CGRect rectCenteredInRect(CGRect rect, CGRect mainRect)
{
	return CGRectOffset(rect,
						CGRectGetMidX(mainRect)-CGRectGetMidX(rect),
						CGRectGetMidY(mainRect)-CGRectGetMidY(rect));
}

@interface BigTextView : UIView
+ (void) bigTextWithString:(NSString *)theString;
@end

@implementation BigTextView
{
    NSString *baseString;
}

- (id) initWithString: (NSString *) theString
{
    if (self = [super initWithFrame:CGRectZero])
    {
        baseString = theString;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        tapRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void) dismiss
{
    [self removeFromSuperview];
}

+ (void) bigTextWithString:(NSString *)theString
{
	BigTextView *theView = [[BigTextView alloc] initWithString:theString];
	theView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5f];
    
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:theView];
    
    PREPCONSTRAINTS(theView);
    STRETCH_VIEW(window, theView);

	return;
}

- (void) drawRect:(CGRect)rect
{
	[super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Create a geometry with width greater than height
    CGRect orientedRect = self.bounds;
    if (orientedRect.size.height > orientedRect.size.width)
        orientedRect.size = CGSizeMake(orientedRect.size.height, orientedRect.size.width);
    
    // Rotate 90 deg to write text horizontally along window's vertical axis
	CGContextRotateCTM(context, -M_PI_2);
	CGContextTranslateCTM(context, -self.frame.size.height, 0.0f);
	
	// Draw a lovely gray backsplash
	[[[UIColor darkGrayColor] colorWithAlphaComponent:0.75f] set];
    CGRect insetRect = CGRectInset(orientedRect, orientedRect.size.width * 0.05f, orientedRect.size.height * 0.35f);
	[[UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:32.0f] fill];
	CGContextFillPath(context);
    
    // Inset again for the text
    insetRect = CGRectInset(insetRect, insetRect.size.width * 0.05f, insetRect.size.height * 0.05f);

	// Iterate until finding a set of font traits that fits this rectangle
    UIFont *textFont;
    NSString *fontFace = @"HelveticaNeue-Bold";
    CGSize fullSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);

	for(CGFloat fontSize = 18; fontSize < 300; fontSize++ )
	{
        // Search until the font size is too big
		textFont = [UIFont fontWithName:fontFace size: fontSize];
		CGSize textSize = [baseString sizeWithFont:textFont constrainedToSize:fullSize];
		if (textSize.width > insetRect.size.width)
        {
            // Ease back on font size to prior level
            textFont = [UIFont fontWithName:fontFace size: fontSize - 1];
			break;
        }
	}
    
	// Establish a frame that just encloses the text at the maximum size
    CGSize textSize = [baseString sizeWithFont:textFont constrainedToSize:fullSize];
    CGRect textFrame = (CGRect){.size = textSize};
	CGRect centerRect = rectCenteredInRect(textFrame, insetRect);
    
    // Draw the string in white
    [[UIColor whiteColor] set];
    [baseString drawInRect:centerRect withFont:textFont];
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) action: (id) sender
{
	[BigTextView bigTextWithString:@"303-555-1212"];
}

- (void) viewDidAppear:(BOOL)animated
{
	[BigTextView bigTextWithString:@"303-555-1212"];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
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