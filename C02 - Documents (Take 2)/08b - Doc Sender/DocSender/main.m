/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "DocWatchHelper.h"

#define DOCUMENTS_PATH  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface TestBedViewController : UITableViewController <UIDocumentInteractionControllerDelegate>
@end

@implementation TestBedViewController
{
    NSArray *items;
    DocWatchHelper *helper;
    UIDocumentInteractionController *dic;
    NSURL *fileURL;
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

#pragma mark DIC 

- (void) dismissIfNeeded
{
    // Proactively dismiss any visible popover
    if (dic)
        [dic dismissMenuAnimated:YES];
}

- (void) documentInteractionControllerDidDismissOptionsMenu: (UIDocumentInteractionController *) controller
{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    dic = nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissIfNeeded];
    
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *title = cell.textLabel.text;
    NSString *path = [DOCUMENTS_PATH stringByAppendingPathComponent:title];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"File missing. Bailing");
        return;
    }
    
    fileURL = [NSURL fileURLWithPath:path];
    dic = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    dic.delegate = self;
    [dic presentOptionsMenuFromRect:cell.frame inView:self.tableView animated:YES];
}


#pragma mark -

// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
	return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    return cell;
}

- (void) scanDocuments
{
    NSString *path = DOCUMENTS_PATH;
    items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    [self.tableView reloadData];
}

// Set up table
- (void) loadView
{
    [super loadView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self scanDocuments];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kDocumentChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         // Contents changed
         [self scanDocuments];
     }];
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    helper = [DocWatchHelper watcherForPath:path];
}
@end

#pragma mark -

#pragma mark Application Setup
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