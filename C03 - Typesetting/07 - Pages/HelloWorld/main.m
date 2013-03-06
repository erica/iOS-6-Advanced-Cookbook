/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "BookController.h"
#import "MarkupHelper.h"
#import "Utility.h"

@interface ASView : UIView 
@property (nonatomic, strong) NSAttributedString *attributedString;
@end

@implementation ASView
- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
        self.backgroundColor = [UIColor clearColor];
    return self;
}

- (void) drawRect:(CGRect)rect
{
	[super drawRect: rect];
    [_attributedString drawInRect:self.bounds];
}
@end

@interface TestBedViewController : UIViewController <BookControllerDelegate>
@end

@implementation TestBedViewController
{
    BookController *bookController;
    NSAttributedString *string;
    NSArray *pageArray;
}

- (NSArray *) findPageSplitsForString: (NSAttributedString *) theString withPageSize: (CGSize) pageSize
{
    NSInteger stringLength = theString.length;
    NSMutableArray *pages = [NSMutableArray array];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) theString);
    
    CFRange baseRange = {0,0};
    CFRange targetRange = {0,0};
    do {
        CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, baseRange, NULL, pageSize, &targetRange);
        NSRange destRange = {baseRange.location, targetRange.length};
        [pages addObject:[NSValue valueWithRange:destRange]];
        baseRange.location += targetRange.length;
    } while(baseRange.location < stringLength);
    
    CFRelease(frameSetter);
    return pages;
}

// Provide a view controller on demand for the given page number
- (id) viewControllerForPage: (int) pageNumber
{
    if (pageNumber < 0) return nil;
    
    // Provide endleafs before text and after the last (odd) page
    if ((pageNumber == 0) ||
        (pageNumber == pageArray.count + 1))
    {
        UIViewController *controller = [[UIViewController alloc] init];
        controller.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        return controller;
    }
    
    if (pageNumber > pageArray.count) return nil;
    
    // Adjust page number to take initial endleaf into account
    pageNumber--;
    
    // Establish a new controller
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.backgroundColor = [UIColor whiteColor];
    
    // Look up the text that needs to be shown
    NSRange offsetRange = [[pageArray objectAtIndex:pageNumber] rangeValue];
    NSAttributedString *subString = [string attributedSubstringFromRange:offsetRange];
    
    // Add subview
    ASView *customView = [[ASView alloc] initWithFrame:CGRectZero];
    customView.attributedString = subString;
    [controller.view addSubview:customView];
    PREPCONSTRAINTS(customView);
    STRETCH_VIEW(controller.view, customView);

    // Return the new controller
    return controller;
}

- (void) viewWillAppear:(BOOL)animated
{
    pageArray = [self findPageSplitsForString:string withPageSize:self.view.bounds.size];
    [bookController moveToPage:1];
}

- (void) viewDidLoad
{
    // Add the child controller, and set it to the first page
    UIView *bcView = bookController.view;
    [self.view addSubview:bcView];
    PREPCONSTRAINTS(bcView);
    STRETCH_VIEW(self.view, bcView);
    
    [self addChildViewController:bookController];
    [bookController didMoveToParentViewController:self];
    [bookController moveToPage:0];
}

- (void) loadView
{
    [super loadView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
    NSString *markup = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    string = [MarkupHelper stringFromMarkup:markup];
    
    // Establish the page view controller
    bookController = [BookController bookWithDelegate:self];
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