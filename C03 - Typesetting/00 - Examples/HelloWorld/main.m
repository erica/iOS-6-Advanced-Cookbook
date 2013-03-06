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
@property (nonatomic, strong) NSAttributedString *string;
@end

@implementation CTView
@synthesize string;

- (id) initWithAttributedString: (NSAttributedString *) aString
{
	if (!(self = [super initWithFrame:CGRectZero])) return self;
    
	self.backgroundColor = [UIColor clearColor];
	string = aString;
	
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
	CGRect insetRect = CGRectInset(self.frame, 5.0f, 5.0f);
	CGPathAddRect(path, NULL, insetRect);
    
	// Draw the text
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.string);
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.string.length), path, NULL);
	CTFrameDraw(theFrame, context);
	
    // Clean up
	CFRelease(framesetter);
	CFRelease(path);
	CFRelease(theFrame);
}
@end

@interface TestBedViewController : UIViewController
{
    UITextView *textView;
    CTView *ctView;
    NSAttributedString *attributedString;
    NSString *lorem;
}
@end

@implementation TestBedViewController

- (void) testSet_2
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 40.0f;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    attributedString = [[NSAttributedString alloc] initWithString:lorem attributes: attributes];

    textView.attributedText = attributedString;
}

- (void) testSet_1
{
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc]  init];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 40.0f;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    attributedString = [[NSAttributedString alloc] initWithString:lorem attributes: attributes];
    [mas appendAttributedString:attributedString];

    ctView = [[CTView alloc] initWithAttributedString:mas];
    [self.view addSubview:ctView];
    
    PREPCONSTRAINTS(ctView);
    STRETCH_VIEW(self.view, ctView);}

- (void) example_6
{
    FancyString *string = [FancyString string];
    
    [string setAlignment:@"left"];
    [string appendFormat:@"Hello World!\n"];
    [string setAlignment:@"center"];
    [string appendFormat:@"Hello World!\n"];
    [string setAlignment:@"right"];
    [string appendFormat:@"Hello World!\n"];
    
    textView.attributedText = string.string;
}

- (void) example_5
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.firstLineHeadIndent = 36.0f;
    paragraphStyle.lineSpacing = 8.0f;
    paragraphStyle.paragraphSpacing = 24.0f;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Futura" size:14.0f];
    attributedString = [[NSAttributedString alloc] initWithString:lorem attributes: attributes];
    
    textView.attributedText = attributedString;
}


- (void) example_4
{
    // Test with Zapfino, Papyrus: Thanks, Jason Foreman
    
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc]  init];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Futura" size:24.0f];
    attributedString = [[NSAttributedString alloc] initWithString:@"Ligatures [on] " attributes: attributes];
    [mas appendAttributedString:attributedString];

    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Times New Roman" size:36.0f];
    attributes[NSLigatureAttributeName] = @1;
    attributedString = [[NSAttributedString alloc] initWithString:@"ffi final " attributes: attributes];
    [mas appendAttributedString:attributedString];
    
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Futura" size:24.0f];
    attributedString = [[NSAttributedString alloc] initWithString:@" [off] " attributes: attributes];
    [mas appendAttributedString:attributedString];

    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Times New Roman" size:36.0f];
    attributes[NSLigatureAttributeName] = @0;
    attributedString = [[NSAttributedString alloc] initWithString:@"ffi final " attributes: attributes];
    [mas appendAttributedString:attributedString];   
    
    ctView = [[CTView alloc] initWithAttributedString:mas];
    [self.view addSubview:ctView];
    
    PREPCONSTRAINTS(ctView);
    STRETCH_VIEW(self.view, ctView);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [ctView setNeedsDisplay];    
}

- (void) example_3
{
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 3.0f;
    shadow.shadowOffset = CGSizeMake(4.0f, 4.0f);
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Futura" size:36.0f];
    attributes[NSForegroundColorAttributeName] = [UIColor grayColor];
    attributes[NSShadowAttributeName] = shadow;
    
    attributedString = [[NSAttributedString alloc] initWithString:@"Hello World" attributes: attributes];
    
    textView.attributedText = attributedString;
}

- (void) example_2
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Futura" size:36.0f];
    attributes[NSForegroundColorAttributeName] = [UIColor grayColor];
    attributes[NSStrokeWidthAttributeName] = @(3.0);
    
    attributedString = [[NSAttributedString alloc] initWithString:@"Hello World" attributes: attributes];
    
    textView.attributedText = attributedString;
}

- (void) example_1
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Futura" size:36.0f];
    attributes[NSForegroundColorAttributeName] = [UIColor grayColor];
    
    attributedString = [[NSAttributedString alloc] initWithString:@"Hello World" attributes: attributes];
    
    textView.attributedText = attributedString;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];

    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.editable = NO;
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    
    lorem = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis eleifend risus id arcu volutpat porta. Cras vel dolor nec lectus iaculis luctus. Sed mollis, ante at bibendum pulvinar, purus dui pellentesque ipsum, quis pulvinar diam nisl in massa. Curabitur varius malesuada suscipit.\nPhasellus dictum, mi a rhoncus convallis, sapien nulla venenatis nisl, id consectetur tellus dui et est. Nullam tempor dapibus diam. Pellentesque urna enim, viverra et fringilla nec, lobortis non libero. Morbi sit amet erat sit amet lacus tempus venenatis vitae nec nulla.";

    [self testSet_2];
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