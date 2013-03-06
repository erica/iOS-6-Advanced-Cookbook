//
//  TestBedSuperViewController.m
//  HelloWorld
//
//  Created by Erica Sadun on 10/31/12.
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#import "TestBedSuperViewController.h"

@implementation TestBedSuperViewController

#pragma mark - GUI

- (void) setPrematchGUI
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Match", @selector(requestMatch));
    // Customize in subclass
}

- (void) activateGameGUI
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Quit", @selector(finishMatch));
    // Customize in subclass
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

- (void)match:(GKMatch *) aMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    // Please implement in subclass
}

- (void)match:(GKMatch *) aMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    if (state == GKPlayerStateDisconnected)
    {
        [_match disconnect];
        [self setPrematchGUI];
        alert(@"Match was disconnected");
    }
    else if (state == GKPlayerStateConnected)
    {
        _opponentName = @"Your Opponent";
        
        if (!_matchStarted && !_match.expectedPlayerCount)        {
            [GKPlayer loadPlayersForIdentifiers:@[playerID] withCompletionHandler:^(NSArray *players, NSError *error)
             {
                 [self activateGameGUI];
                 NSString *opponentName = playerID;
                 if (!error)
                 {
                     GKPlayer *opponent = [players lastObject];
                     opponentName = opponent.displayName;
                 }
                 _opponentName = opponentName;
                 // alert(@"Commencing Match with %@", opponentName);
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
    if (_matchStarted)
        return;
    
    if (viewController)
    {
        NSLog(@"Match found");
        [self dismissViewControllerAnimated:YES completion:nil];
        _match = aMatch;
        _match.delegate = self;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // Normal matches now wait for player connection
    
    // Invited connections may be ready to go now. If so, begin
    if (!_matchStarted && !_match.expectedPlayerCount)
    {
        // 2-player game.
        NSString *playerID = [_match.playerIDs lastObject];
        [GKPlayer loadPlayersForIdentifiers:@[playerID] withCompletionHandler:^(NSArray *players, NSError *error)
         {
             [self activateGameGUI];
             if (error) return;
             GKPlayer *opponent = [players lastObject];
             _opponentName = opponent.displayName;
             // alert(@"Commencing Match with %@", opponent.displayName);
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

#pragma mark - Start/Stop Games

- (void) finishMatch
{
    [_match disconnect];
    [self setPrematchGUI];
}

- (void) requestMatch
{
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

#pragma mark - Initialization
- (void) establishPlayer
{
    UIViewController __weak *weakSelf = self;
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
    srandom(time(0));
    
    [[NSNotificationCenter defaultCenter] addObserverForName:GKPlayerAuthenticationDidChangeNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
     {
         BOOL authenticated = [GKLocalPlayer localPlayer].isAuthenticated;
         NSLog(@"User %@ authenticated", authenticated ? @"has" : @"is not");
         if (authenticated)
         {
             [self setPrematchGUI];
             [self addInvitationHandler];
         }
     }];
}
@end

