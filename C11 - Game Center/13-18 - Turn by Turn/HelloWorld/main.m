/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "TurnByTurnHelper.h"
#import "ModalSheetDelegate.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController <MatchDelegate>
@end

@implementation TestBedViewController
{
    UITextView *textView;
    UIButton *goButton;
    UIButton *quitButton;
    UIToolbar *toolbar;
    
    MatchHelper *currentMatch;
    TurnByTurnHelper *turnByTurnHelper;
}

typedef enum
{
    kDisabled,
    kNoGames,
    kMyTurn,
    kYourTurn,
    kInactiveMatch,
} gamestate;

#pragma mark - GUI

- (void) enableNavBar: (BOOL) yorn
{
    for (UIBarItem *item in self.navigationItem.leftBarButtonItems)
        item.enabled = yorn;
    for (UIBarItem *item in self.navigationItem.rightBarButtonItems)
        item.enabled = yorn;
}

- (void) enableToolbar: (BOOL) yorn
{
    for (UIBarItem *item in toolbar.items)
        item.enabled = yorn;
}

- (void) updateGUI: (gamestate) state
{
    // Right bbi is always New Match
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Get Match", @selector(getMatch));
    
    // disable everything
    NSArray *controls = @[goButton, quitButton];
    for (UIControl *control in controls)
        control.enabled = NO;
    [self enableNavBar:NO];
    [self enableToolbar:NO];
    
    switch (state)
    {
        case kDisabled:
            // Entire GUI disabled
            break;
        case kNoGames:
            // No game displayed
            self.navigationItem.leftBarButtonItem = nil;
            [self enableNavBar:YES];
            [self enableToolbar:YES];
            break;
        case kMyTurn:
            [self enableNavBar:YES];
            [self enableToolbar:YES];
            goButton.enabled = YES;
            quitButton.enabled = YES;
            break;
        case kYourTurn:
            [self enableNavBar:YES];
            [self enableToolbar:YES];
            goButton.enabled = NO;
            quitButton.enabled = YES;
            break;
        case kInactiveMatch:
            [self enableNavBar:YES];
            [self enableToolbar:YES];
            self.navigationItem.rightBarButtonItem = BARBUTTON(@"Remove", @selector(removeMatch));
            break;
        default:
            break;
    }
}

#pragma mark - Match Handling

- (void) getMatch
{
    [turnByTurnHelper requestMatch];
}

- (void) chooseMatch: (MatchHelper *) helper
{
    NSLog(@"Choose Match: %@", helper);

    textView.text = @"";

    if (!helper)
    {
        // no game
        currentMatch = nil;
        [self updateGUI:kNoGames];
        return;
    }
    
    currentMatch = helper;
    self.navigationItem.leftBarButtonItem = BARBUTTON(helper.matchID, @selector(nextMatch));
    textView.text = @"loading...";

    // Check for games that are over
    BOOL done = helper.matchIsDone;
    if (done)
    {
        [self updateGUI:kInactiveMatch];
        textView.text = @"Match is done";
        return;
    }
    
    // Match is not done
    [self updateGUI: helper.isMyTurn ? kMyTurn : kYourTurn];
    MatchHelper __weak *weakHelper = currentMatch;
    
    [currentMatch loadDataWithCompletion:^(BOOL success) {
       if (success)
       {
           NSArray *array = weakHelper.object;
           if (!array || (array.count == 0))
               array = @[@""];
           textView.text = array[0];
       }
    }];
}

- (void) nextMatch
{
    if (turnByTurnHelper.matches.count == 0)
    {
        [self chooseMatch:nil];
        return;
    }
    
    if (!currentMatch)
        currentMatch = turnByTurnHelper.matches[0];
    int index = [turnByTurnHelper.matches indexOfObject:currentMatch];
    index = (index + 1) % turnByTurnHelper.matches.count;
    currentMatch = turnByTurnHelper.matches[index];
    [self chooseMatch:currentMatch];
}

- (void) takeTurn: (MatchHelper *) match
{
    BOOL isCurrentMatch = matchEqual(currentMatch.match, match.match);
    BOOL matchEnded = match.matchIsDone;
    
    // Should I quit?
    if (matchEnded && match.amActive)
    {
        [match winMatch];
    }
    
    // Update ended match?
    if (matchEnded)
    {
        if (isCurrentMatch)
            [self chooseMatch:currentMatch];
        else
            alert(@"Match %@ has ended", match.matchID);
        return;
    }
    
    // Match has not ended. It is someone's turn
    if (!isCurrentMatch && match.isMyTurn)
    {
        alert(@"Your turn for match %@", match.matchID);
        return;
    }
    
    if (!isCurrentMatch)
    {
        NSLog(@"Non-turn activity on match %@", match.matchID);
        return;
    }
    
    // It is the current match and it is your turn
    [self chooseMatch:currentMatch];
}

- (void) removeMatch
{
    if (!currentMatch)
    {
        NSLog(@"Error. Expected match. Bailing");
        return;
    }
    
    if (!currentMatch.matchIsDone)
    {
        NSLog(@"Error. Expected completed match. Bailing.");
        return;
    }
    
    [turnByTurnHelper removeMatch:currentMatch];
    currentMatch = nil;
    [self nextMatch];
}

# pragma mark - GamePlay
- (NSString *) requestBaseFromUser
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select a Base" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"A", @"T", @"G", @"C", nil];
    ModalSheetDelegate *delegate = [ModalSheetDelegate delegateWithSheet:sheet];
    int result = [delegate showInView:self.view];
    return @[@"A", @"T", @"G", @"C"][result];
}

- (void) getBase
{
    if (!currentMatch)
    {
        NSLog(@"Error: Attempting to move when there is no match");
        return;
    }
    
    goButton.enabled = NO;
    
    // Retrieve current state
    NSArray *array = currentMatch.object;
    if (!array || (array.count == 0))
        array = @[@""];
    NSString *string = array[0];

    NSString *result = [self requestBaseFromUser];
    NSString *newString = [string stringByAppendingString:result];
    textView.text = newString;
    
    currentMatch.object = @[newString];
    [currentMatch endTurnWithCompletion:^(BOOL success)
     {
         [self updateGUI:kYourTurn];
     }];
}

- (void) quitMatch
{
    NSLog(@"User requests game quit");
    [currentMatch quitMatch];
    [self chooseMatch:currentMatch];
}

#pragma mark - Cleanup / Debug
- (void) reenable: (UIBarButtonItem *) bbi
{
    self.title = nil;
    [self chooseMatch: nil];
}

- (void) resetGameCenter: (UIBarButtonItem *) bbi
{
    if (turnByTurnHelper.matches.count == 0)
    {
        NSLog(@"No matches to quit");
        return;
    }

    [self updateGUI:kDisabled];
    self.navigationItem.leftBarButtonItem = nil;
    self.title = @"Resetting";
    currentMatch = nil;
    [turnByTurnHelper removeAllMatches];
    
    // Arbitrary time to complete
    [self performSelector:@selector(reenable:) withObject:bbi afterDelay:12.0f];
}

#pragma mark - Initialization
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

- (UIButton *) buttonWithName: (NSString *) name selector: (SEL) selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:name forState:UIControlStateNormal];
    [button setTitleColor:COOKBOOK_PURPLE_COLOR forState:UIControlStateNormal];
    button.enabled = NO;
    [self.view addSubview:button];
    PREPCONSTRAINTS(button);
    return button;
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    textView = [[UITextView alloc] init];
    
    textView.font = [UIFont fontWithName:@"Futura" size:14.0f];
    textView.backgroundColor = [UIColor colorWithRed:1.0f green:0.5f blue:0.5f alpha:1.0f];
    textView.editable = NO;
    
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    CONSTRAIN(self.view, textView, @"H:|-[textView(>=0)]-|");
    CONSTRAIN_VIEWS(self.view, @"V:|-60-[textView(==80)]", NSDictionaryOfVariableBindings(textView));
    
    goButton = [self buttonWithName:@"Go" selector:@selector(getBase)];
    CENTER_VIEW_H(self.view, goButton);
    CONSTRAIN(self.view, goButton, @"V:|-[goButton(==30)]");
    CONSTRAIN(self.view, goButton, @"H:[goButton(==100)]");
    
    quitButton = [self buttonWithName:@"Quit" selector:@selector(quitMatch)];
    CENTER_VIEW_H(self.view, quitButton);
    CONSTRAIN(self.view, quitButton, @"V:|-160-[quitButton(==30)]");
    CONSTRAIN(self.view, quitButton, @"H:[quitButton(==100)]");
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    [self.view addSubview:toolbar];
    PREPCONSTRAINTS(toolbar);
    STRETCH_VIEW_H(self.view, toolbar);
    ALIGN_VIEW_BOTTOM(self.view, toolbar);
    
    TestBedViewController __weak *weakself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:GKPlayerAuthenticationDidChangeNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         BOOL authenticated = [GKLocalPlayer localPlayer].isAuthenticated;
         NSLog(@"User %@ authenticated", authenticated ? @"has" : @"is not");
         if (authenticated)
         {
             turnByTurnHelper = [[TurnByTurnHelper alloc] init];
             turnByTurnHelper.delegate = self;
             [GKTurnBasedEventHandler sharedTurnBasedEventHandler].delegate = turnByTurnHelper;
             
             [turnByTurnHelper loadMatchesWithCompletion:^()
              {
                  [weakself nextMatch];
              }];
             
             toolbar.items = @[
             SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil),
             BARBUTTON_TARGET(@"[List]", turnByTurnHelper, @selector(listMatches)),
             BARBUTTON(@"[Boom]", @selector(resetGameCenter:)),
             SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil),
             ];

             UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
             NSDictionary *controlAttributeDictionary = @{UITextAttributeFont : font};
             for (UIBarItem *item in toolbar.items)
                 [item setTitleTextAttributes:controlAttributeDictionary forState:UIControlStateNormal];
         }
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
    [[UIToolbar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
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