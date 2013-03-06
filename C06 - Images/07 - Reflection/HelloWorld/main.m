/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ReflectingViewController.h"
#import "TableInACan.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define RESIZABLE(_VIEW_) [_VIEW_ setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth]

@interface TestBedViewController : ReflectingViewController <CannedDelegate>
@end

@implementation TestBedViewController
{
    TableInACan *cannedTable;
}

- (void) action: (id) sender
{
    // noop
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));

    cannedTable = [TableInACan tableWithList:@[@"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten", @"Eleven", @"Twelve"]];
    cannedTable.cannedDelegate = self;
    RESIZABLE(cannedTable);
    [self.backsplash addSubview:cannedTable];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    cannedTable.frame = self.backsplash.frame;
    [cannedTable reloadData];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.backsplash setupReflection];
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