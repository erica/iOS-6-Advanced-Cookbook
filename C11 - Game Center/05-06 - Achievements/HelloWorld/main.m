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
#define GKBEGINNER    @"com.sadun.cookbook.greatStart"

@interface TestBedViewController : UIViewController <GKGameCenterControllerDelegate>
@end

@implementation TestBedViewController
- (void) unlockAchievement
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: GKBEGINNER];
    if (achievement)
    {
        achievement.percentComplete = 100.0f;
        achievement.showsCompletionBanner = YES;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (error)
             {
                 NSLog(@"Error reporting achievement: %@", error.localizedDescription);
                 return;
             }
             
             NSLog(@"Achievement is recorded");
         }];
    }
}

- (void) resetAchievements
{
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error)
         {
             NSLog(@"Error resetting achievements: %@", error.localizedDescription);
             return;
         }
         
         NSLog(@"Achievements are reset");
     }];
}

- (void) checkAchievement
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error)
        {
            NSLog(@"Error loading achievements: %@", error.localizedDescription);
            return;
        }
 
        NSLog(@"Achievements");
        
        for (GKAchievement *achievement in achievements)
        {
            NSLog(@"Achievement: %@ : %f", achievement.identifier, achievement.percentComplete);
            if ([achievement.identifier isEqualToString:GKBEGINNER])
            {
                // unlock some feature
            }
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
    gvc.viewState = GKGameCenterViewControllerStateAchievements;
    [self presentViewController:gvc animated:YES completion:nil];
}

- (void) updateUserGUI
{
    BOOL authenticated = [GKLocalPlayer localPlayer].isAuthenticated;
    NSLog(@"User %@ authenticated", authenticated ? @"has" : @"is not");
    self.navigationItem.rightBarButtonItem = nil;
    if (authenticated)
    {
        self.navigationItem.rightBarButtonItems = @[
        BARBUTTON(@"Unlock", @selector(unlockAchievement)),
        BARBUTTON(@"Reset", @selector(resetAchievements)),
        BARBUTTON(@"GCVC", @selector(showGameCenterViewController)),
        BARBUTTON(@"Check", @selector(checkAchievement)),
        ];
        
        [self checkAchievement];
    }
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
    [[NSNotificationCenter defaultCenter] addObserverForName:GKPlayerAuthenticationDidChangeNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         [self updateUserGUI];
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