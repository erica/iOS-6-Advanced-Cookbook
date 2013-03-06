/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "FakePerson.h"
#import "Utility.h"
#import "ABWrappers.h"

@interface TestBedViewController : UITableViewController <ABPersonViewControllerDelegate, UISearchBarDelegate>
{
}
@end

@implementation TestBedViewController
{
    NSArray *matches;
    NSArray *filteredArray;
    UISearchBar *searchBar;
    UISearchDisplayController *searchController;
}

// Return the number of table sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Return the number of rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (aTableView == self.tableView)
        return matches.count;
    
    matches = [ABContactsHelper contactsMatchingName:searchBar.text];
    matches = [matches sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return matches.count;
}

// Produce a cell for the given index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Dequeue or create a cell
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    
    ABContact *contact = [matches objectAtIndex:indexPath.row];
    cell.textLabel.text = contact.compositeName;
	return cell;
}

- (BOOL)personViewController: (ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    // Reveal the item that was selected
    if ([ABContact propertyIsMultiValue:property])
    {
        NSArray *array = [ABContact arrayForProperty:property inRecord:person];
        NSLog(@"%@", [array objectAtIndex:identifierForValue]);
    }
    else
    {
        id object = [ABContact objectForProperty:property inRecord:person];
        NSLog(@"%@", [object description]);
    }
    
    return NO;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ABContact *contact = [matches objectAtIndex:indexPath.row];
    ABPersonViewController *pvc = [[ABPersonViewController alloc] init];
    pvc.displayedPerson = contact.record;
    pvc.personViewDelegate = self;
    pvc.allowsEditing = YES; // optional editing
    [self.navigationController pushViewController:pvc animated:YES];
}

// Via Jack Lucky. Handle the cancel button by resetting the search text
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    NSLog(@"Restoring contacts");
    matches = [ABContactsHelper contacts];
    matches = [matches sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [self.tableView reloadData];
}

- (void) enableGUI: (BOOL) yorn
{
    if (!yorn)
    {
         [ABStandin showDeniedAccessAlert];
        return;
    }
    
    // Create a search bar
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	searchBar.tintColor = COOKBOOK_PURPLE_COLOR;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.keyboardType = UIKeyboardTypeAlphabet;
    searchBar.delegate = self;
	self.tableView.tableHeaderView = searchBar;
	
	// Create the search display controller
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
    
    // Normal table
    matches = [ABContactsHelper contacts];
    matches = [matches sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void) loadView
{
    [super loadView];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kAuthorizationUpdateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
     {
         NSNumber *granted = note.object;
         [self enableGUI:granted.boolValue];
     }];
    [ABStandin requestAccess];
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
    TestBedViewController *tbvc;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srandom(time(0));
    
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	tbvc = [[TestBedViewController alloc] init];
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