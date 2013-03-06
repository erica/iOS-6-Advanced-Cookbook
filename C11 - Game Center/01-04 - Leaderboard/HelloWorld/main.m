/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ModalAlertDelegate.h"
#import "Utility.h"

#define GKCATEGORY    @"com.sadun.cookbook.topPoints"

@interface TestBedViewController : UIViewController <GKGameCenterControllerDelegate>
@end

@implementation TestBedViewController
- (NSNumber *) requestScore
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter your score" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:alert];
    int response = [delegate show];
    if (!response) return nil;
    
    NSUInteger score = [[[alert textFieldAtIndex:0] text] intValue];
    return @(score);
}

- (void) createScore
{
    // Fetch a "score"
    NSNumber *userScore = [self requestScore];
    if (!userScore) return;
    
    GKScore *score = [[GKScore alloc] initWithCategory:GKCATEGORY];
    score.value = userScore.intValue;
    [score reportScoreWithCompletionHandler:^(NSError *error){
        if (error)
        {
            NSLog(@"Error submitting score to game center: %@", error.localizedDescription);
            return;
        }
        
        NSLog(@"Success. Score submitted.");
    }];
}

- (void) peekAtLeaderboard: (GKLeaderboard *) leaderboard
{

    leaderboard.range = NSMakeRange(1, 10); // top ten scores. Default range is 1,25
    leaderboard.timeScope = GKLeaderboardTimeScopeWeek; // Within last week
    
    // Load in the scores
    [leaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error)
    {
        if (error)
        {
            NSLog(@"Error retrieving leaderboard scores: %@", error.localizedDescription);
            return;
        }

        // Retrieve player ids
        NSMutableArray *array = [NSMutableArray array];
        for (GKScore *score in scores)
            [array addObject:score.playerID];
        
        // Load the player names
        [GKPlayer loadPlayersForIdentifiers:array withCompletionHandler:^(NSArray *players, NSError *error)
        {
            if (error)
            {
                // Report only with player ids
                for (GKScore *score in scores)
                    NSLog(@"[%2d] %@: %@ (%@)", score.rank, score.playerID, score.formattedValue, score.date);
                return;
            }

            for (int i = 0; i < scores.count; i++)
            {
                // Report with actual player names
                GKPlayer *aPlayer = [players objectAtIndex:i];
                GKScore *score = [scores objectAtIndex:i];
                NSLog(@"[%2d] %@: %@ (%@)", score.rank, aPlayer.displayName, score.formattedValue, score.date);
            }
        }];
    }];
}

- (void) peekAtLeaderboards
{
    // Fetch the leaderboards
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error retrieving leaderboards: %@", error.localizedDescription);
             return;
         }
         
         // Iterate through each leaderboard and display its details
         for (GKLeaderboard *leaderboard in leaderboards)
         {
             NSString *category = leaderboard.category;
             NSString *title = leaderboard.title;
             NSLog(@"%@ : %@", category, title);
             [self peekAtLeaderboard:leaderboard];
         }
     }];
}


- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showGameCenterViewController
{
    GKGameCenterViewController *gvc = [[GKGameCenterViewController alloc] init];
    gvc.gameCenterDelegate = self;
    [self presentViewController:gvc animated:YES completion:nil];
}

- (void) updateUserGUI
{
    BOOL authenticated = [GKLocalPlayer localPlayer].isAuthenticated;
    NSLog(@"User %@ authenticated", authenticated ? @"has" : @"is not");
    self.navigationItem.rightBarButtonItem = nil;
    if (authenticated)
        self.navigationItem.rightBarButtonItems = @[
        BARBUTTON(@"Score", @selector(createScore)),
        BARBUTTON(@"Peek", @selector(peekAtLeaderboards)),
        BARBUTTON(@"GCVC", @selector(showGameCenterViewController)),
        ];
}

- (void) establishPlayer
{
    TestBedViewController __weak *weakSelf = self;
    [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *controller, NSError *error)
    {
        if (error)
        {
            NSLog(@"Error authenticating: %@", error.localizedDescription);
            alert(@"Restore game features at any time by logging in via the Game Center app.");
            return;
        }
        if (controller)
        {
            // User has not yet authenticated
            [weakSelf presentViewController:controller animated:YES completion:nil];
        }
    };
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self establishPlayer];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    TestBedViewController __weak *weakself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:GKPlayerAuthenticationDidChangeNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         [weakself updateUserGUI];
     }];
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