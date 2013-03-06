/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "MarkupHelper.h"
#import "Utility.h"

@interface QuickItem : NSObject <QLPreviewItem>
@property (nonatomic, strong) NSString *path;
@property (readonly) NSString *previewItemTitle;
@property (readonly) NSURL *previewItemURL;
@end

@implementation QuickItem
- (NSString *) previewItemTitle
{
    return @"Generated PDF";
}

- (NSURL *) previewItemURL
{
    return [NSURL fileURLWithPath:_path];
}
@end

@interface TestBedViewController : UIViewController <QLPreviewControllerDataSource>
@end

@implementation TestBedViewController
{
    NSAttributedString *string;
    NSArray *pageArray;
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index;
{
    QuickItem *item = [[QuickItem alloc] init];
    item.path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/results.pdf"];
    return item;
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

- (void) dumpToPDFFile: (NSString *) pdfPath
{
    CGRect theBounds = CGRectMake(0.0f, 0.0f, 480.0f, 640.0f);
    CGRect insetRect = CGRectInset(theBounds, 0.0f, 10.0f);
    
    NSArray *pageSplits = [self findPageSplitsForString:string withPageSize:insetRect.size];
    int offset = 0;

    UIGraphicsBeginPDFContextToFile(pdfPath, theBounds, nil);
    
    for (NSValue *pageStart in pageSplits)
    {
        UIGraphicsBeginPDFPage();
        NSRange offsetRange = {offset, pageStart.rangeValue.length};
        NSAttributedString *subString = [string attributedSubstringFromRange:offsetRange];
        offset += offsetRange.length;
        [subString drawInRect:insetRect];
    }
    
    UIGraphicsEndPDFContext();
}

- (void) action
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
    NSString *markup = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    string = [MarkupHelper stringFromMarkup:markup];
    
    NSString *destPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/results.pdf"];
    [self dumpToPDFFile:destPath];
    
    QLPreviewController *controller = [[QLPreviewController alloc] init];
    controller.dataSource = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(action));
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