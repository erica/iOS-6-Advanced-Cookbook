/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController <UIDocumentInteractionControllerDelegate>
@end

@implementation TestBedViewController
{
    NSURL *fileURL;
    UIDocumentInteractionController *dic;
    BOOL canOpen;
}

#pragma mark QuickLook
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (UIView *) documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect) documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
}

#pragma mark Options / Open in Menu

- (void) documentInteractionControllerDidDismissOptionsMenu: (UIDocumentInteractionController *) controller
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    dic = nil;
}

- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller
{
    self.navigationItem.rightBarButtonItem.enabled = canOpen;
    dic = nil;
}

- (void) dismissIfNeeded
{
    // Proactively dismiss any visible popover
    if (dic)
    {
        [dic dismissMenuAnimated:YES];
        self.navigationItem.rightBarButtonItem.enabled = canOpen;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

- (void) action: (UIBarButtonItem *) bbi
{
    [self dismissIfNeeded];
    dic = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    dic.delegate = self;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [dic presentOptionsMenuFromBarButtonItem:bbi animated:YES];
}

- (void) open: (UIBarButtonItem *) bbi
{
    [self dismissIfNeeded];
    dic = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    dic.delegate = self;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [dic presentOpenInMenuFromBarButtonItem:bbi animated:YES];
}

#pragma mark Test for Open-ability
-(BOOL)canOpen: (NSURL *) aFileURL
{
    UIDocumentInteractionController *tmp = [UIDocumentInteractionController interactionControllerWithURL:aFileURL];
    BOOL success = [tmp presentOpenInMenuFromRect:CGRectMake(0,0,1,1) inView:self.view animated:NO];
    [tmp dismissMenuAnimated:NO];
    return success;
}

- (void) viewDidAppear:(BOOL)animated
{
    // Only enable right button if the file can be opened
    canOpen = [self canOpen:fileURL];
    self.navigationItem.rightBarButtonItem.enabled = canOpen;
    
    // This does not work -- It will likely return YES even if no apps can open this file type
    // NSLog(@"%d", [[UIApplication sharedApplication] canOpenURL:fileURL]);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Open in...", @selector(open:));
    self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemAction, @selector(action:));

    // Create a new image if one is not found
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DICImage.jpg"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        UIImage *image = [UIImage imageNamed:@"Default.png"];
        NSData *data = UIImageJPEGRepresentation(image, 1.0f);
        [data writeToFile:filePath atomically:YES];
    }
    fileURL = [NSURL fileURLWithPath:filePath];    
}
@end

#pragma mark - Application Setup -
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end
@implementation TestBedAppDelegate
{
	UIWindow *window;
}
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