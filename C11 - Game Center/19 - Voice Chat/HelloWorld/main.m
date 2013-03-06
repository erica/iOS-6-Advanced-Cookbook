/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ModalAlertDelegate.h"
#import "Utility.h"

@interface TestBedViewController : UIViewController <GKMatchDelegate, GKMatchmakerViewControllerDelegate, UITextViewDelegate>
@end

@implementation TestBedViewController
{
    GKMatch *match;
    BOOL matchStarted;

    UITextView *sendingView;
    UITextView *receivingView;
    UIToolbar *tb;
    
    GKVoiceChat *chat;
    
    AVAudioSession *session;
    BOOL hasEstablishedAudio;
}

#pragma mark - GUI
- (void) activateGameGUI
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Quit", @selector(finishMatch));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Speak", @selector(startSpeaking));

    sendingView.text = @"";
    sendingView.editable = YES;
    sendingView.delegate = self;
    [sendingView becomeFirstResponder];
    
    receivingView.text = @"";
    
    matchStarted = YES;
}

- (void) setPrematchGUI
{
    if (chat)
    {
        chat.active = NO;
        chat = nil;
    }
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Match", @selector(requestMatch));
    self.navigationItem.leftBarButtonItem = nil;
    sendingView.editable = NO;
    sendingView.delegate = nil;
    
    matchStarted = NO;
    match = nil;
}

#pragma mark - Typing gameplay

- (void)textViewDidChange:(UITextView *)textView
{
    NSError *error;
    NSData *dataToSend = STRDATA(sendingView.text);
    BOOL success = [match sendDataToAllPlayers:dataToSend withDataMode:GKMatchSendDataReliable error:&error];
    if (!success)
        NSLog(@"Error sending match data: %@", error.localizedDescription);
}

- (void)match:(GKMatch *) aMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSString *received = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    receivingView.text = received;
}

#pragma mark - Match Connections

- (void)match:(GKMatch *) aMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error
{
    NSLog(@"Connection failed with player %@: %@", playerID, error.localizedDescription);
    [self setPrematchGUI];
}

- (void)match:(GKMatch *) aMatch didFailWithError:(NSError *)error
{
    [self setPrematchGUI];
    alert(@"Lost Game Center Connection: %@", error.localizedDescription);
}

- (void)match:(GKMatch *) aMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    if (state == GKPlayerStateDisconnected)
    {
        [match disconnect];
        [self setPrematchGUI];
        alert(@"Match was disconnected");
    }
    else if (state == GKPlayerStateConnected)
    {
        if (!matchStarted && !match.expectedPlayerCount)        {
            [GKPlayer loadPlayersForIdentifiers:@[playerID] withCompletionHandler:^(NSArray *players, NSError *error)
             {
                 [self activateGameGUI];
                 NSString *opponentName = playerID;
                 if (!error)
                 {
                     GKPlayer *opponent = [players lastObject];
                     opponentName = opponent.displayName;
                     [self establishChat];
                 }
                 alert(@"Commencing Match with %@", opponentName);
             }];
        }
    }
    else
    {
        NSLog(@"Player state changed to unknown");
    }
}

// If you want disconnected matches to try to re-connect
/* - (BOOL)match:(GKMatch *) aMatch shouldReinvitePlayer:(NSString *)playerID
 {
 return YES;
 } */

#pragma mark - Matchmaking

- (void) matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)aMatch
{
    // Already playing. Ignore.
    if (matchStarted)
        return;
    
    if (viewController)
    {
        NSLog(@"Match found");
        [self dismissViewControllerAnimated:YES completion:nil];
        match = aMatch;
        match.delegate = self;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // Normal matches now wait for player connection
    
    // Invited connections may be ready to go now. If so, begin
    if (!matchStarted && !match.expectedPlayerCount)
    {
        // 2-player game.
        NSString *playerID = [match.playerIDs lastObject];
        [GKPlayer loadPlayersForIdentifiers:@[playerID] withCompletionHandler:^(NSArray *players, NSError *error)
         {
             [self activateGameGUI];             
             if (error) return;
             GKPlayer *opponent = [players lastObject];
             [self establishChat];
             alert(@"Commencing Match with %@", opponent.displayName);
         }];
    }
}

- (void) matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    alert(@"Error creating match: %@", error.localizedDescription);
}

#pragma mark - Voice Chat


- (void) muteChat: (GKVoiceChat *) aChat
{
    NSLog(@"Muting chat %@", aChat.name);
    for (NSString *playerID in aChat.playerIDs)
        [aChat setMute:YES forPlayer:playerID];
}

- (void) unmuteChat: (GKVoiceChat *) aChat
{
    NSLog(@"Unmuting chat %@", aChat.name);
    for (NSString *playerID in aChat.playerIDs)
        [aChat setMute:NO forPlayer:playerID];
}

- (void) stopSpeaking
{
    chat.active = NO;
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Speak", @selector(startSpeaking));
}

- (void) startSpeaking
{
    chat.active = YES;
    NSLog(@"%@ %@ %f", chat.name, chat.playerIDs, chat.volume);
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Stop", @selector(stopSpeaking));
}

- (void) establishChat
{
    NSLog(@"Establishing Chat");
    chat = [match voiceChatWithName:@"com.sadun.cookbook.chat1"];
    if (!chat)
    {
        NSLog(@"Error establishing chat!");
        return;
    }
    
    chat.playerStateUpdateHandler = ^(NSString *playerID, GKVoiceChatPlayerState state) {
        switch (state)
        {
            case GKVoiceChatPlayerSpeaking:
                NSLog(@"***Speaking: %@", playerID);
                // Highlight player's picture
                break;
            case GKVoiceChatPlayerSilent:
                NSLog(@"***Silent: %@", playerID);
                // Dim player's picture
                break;
            case GKVoiceChatPlayerConnected:
                NSLog(@"***Connected: %@", playerID);
                // Show player name/picture
                break;
            case GKVoiceChatPlayerDisconnected:
                NSLog(@"***Disconnected: %@", playerID);
                // Hide player name/picture
                break;
        } };
    
    chat.active = NO; // disable mic by setting to NO
    chat.volume = 1.0f; // adjust as needed.

    NSLog(@"Connecting to channel");
    [chat start]; // stop with [chat end];

    NSLog(@"Chat: %@", chat.description);
    NSLog(@"Participants: %@", chat.playerIDs);
    
    // Establishing team chats and direct chat
    /*
     e.g. directChat = [match voiceChatWithName:@"Private Channel 1"];
     Each unique name specifies the chat
     */
    
    // muting: [chat setMute:YES/NO forPlayer: playerID];
}

#pragma mark - Start/Stop Games

- (void) finishMatch
{
    [match disconnect];
    [self setPrematchGUI];
}

- (void) requestMatch
{
    // Clean up any previous game
    sendingView.text = @"";
    receivingView.text = @"";
    
    // This is not a hosted match, which allows up to 16 players
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2; // Between 2 and 4
    request.maxPlayers = 2; // Betseen 2 and 4
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    mmvc.hosted = NO;    
    [self presentViewController:mmvc animated:YES completion:nil];
}

- (void) addInvitationHandler
{
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *invitation, NSArray *playersToInvite)
    {
        // Clean up any in-progress game
        [self finishMatch];
        NSLog(@"Invitation: %@, playersToInvite: %@", invitation, playersToInvite);
        
        if (invitation)
        {
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:invitation];
            mmvc.matchmakerDelegate = self;
            [self presentViewController:mmvc animated:YES completion:nil];
        }
        else if (playersToInvite)
        {
            GKMatchRequest *request = [[GKMatchRequest alloc] init];
            request.minPlayers = 2;
            request.maxPlayers = 2; // 2-player matches for this example
            request.playersToInvite = playersToInvite;
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
            mmvc.matchmakerDelegate = self;
            [self presentViewController:mmvc animated:YES completion:nil];
        }
    };
}

#pragma mark - Toolbar Setup
- (void) clearText
{
    sendingView.text = @"";
    [self textViewDidChange:sendingView];
}

- (void) leaveKeyboardMode
{
    [sendingView resignFirstResponder];
}

- (UIToolbar *) accessoryView
{
	tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
	tb.tintColor = [UIColor darkGrayColor];
	
	NSArray *items = @[
    BARBUTTON(@"Clear", @selector(clearText)),
    SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil),
    BARBUTTON(@"Done", @selector(leaveKeyboardMode)),
    ];
	tb.items = items;
	
	return tb;
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

- (BOOL) establishPlayAndRecordAudioSession
{
    if (hasEstablishedAudio)
        return YES;
    
    NSLog(@"Establishing Audio Session");
    NSError *error;
    session = [AVAudioSession sharedInstance];
    BOOL success = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!success)
    {
        NSLog(@"Error setting session category: %@", error.localizedFailureReason);
        return NO;
    }
    else
    {
        success = [session setActive:YES error:&error];
        if (success)
        {
            NSLog(@"Audio session is active (play and record)");
            hasEstablishedAudio = YES;
            return YES;
        }
        else
        {
            NSLog(@"Error activating audio session: %@", error.localizedFailureReason);
            return NO;
        }
    }
    
    return NO;
}


- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    sendingView = [[UITextView alloc] init];
    receivingView = [[UITextView alloc] init];
    
    sendingView.font = [UIFont fontWithName:@"Futura" size:14.0f];
    sendingView.backgroundColor = [UIColor colorWithRed:1.0f green:0.5f blue:0.5f alpha:1.0f];
    sendingView.inputAccessoryView = [self accessoryView];
    sendingView.editable = NO;
    
    receivingView.editable = NO;
    receivingView.font = [UIFont fontWithName:@"Futura" size:14.0f];
    receivingView.backgroundColor = [UIColor colorWithRed:0.5f green:0.5f blue:1.0f alpha:1.0f];
    receivingView.editable = NO;
    
    [self.view addSubview:sendingView];
    [self.view addSubview:receivingView];
    
    PREPCONSTRAINTS(sendingView);
    PREPCONSTRAINTS(receivingView);
    
    CONSTRAIN(self.view, sendingView, @"H:|-[sendingView(>=0)]-|");
    CONSTRAIN(self.view, receivingView, @"H:|-[receivingView(>=0)]-|");
    
    CONSTRAIN_VIEWS(self.view, @"V:|[sendingView(==80)]-[receivingView(==80)]", NSDictionaryOfVariableBindings(sendingView, receivingView));
    
    [[NSNotificationCenter defaultCenter] addObserverForName:GKPlayerAuthenticationDidChangeNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         BOOL authenticated = [GKLocalPlayer localPlayer].isAuthenticated;
         NSLog(@"User %@ authenticated", authenticated ? @"has" : @"is not");
         if (authenticated)
         {
             [self setPrematchGUI];
             [self addInvitationHandler];
             
             if ([GKVoiceChat isVoIPAllowed])
             {
                 [self establishPlayAndRecordAudioSession];
             }
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