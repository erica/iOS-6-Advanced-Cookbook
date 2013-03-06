/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "TurnByTurnHelper.h"

@implementation TurnByTurnHelper
{
    
}

#pragma mark - Utility
- (MatchHelper *) matchForID: (NSString *) matchID
{
    for (MatchHelper *helper in _matchDictionary.allValues)
        if (matchIDCheck(helper.match, matchID))
            return helper;
    return nil;
}

- (NSArray *) matches
{
    return _matchDictionary.allValues;
}

#pragma mark - Request Match
- (GKMatchRequest *) buildMatchRequest
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2; // Between 2 and 4
    request.maxPlayers = 2; // Betseen 2 and 4
    return request;
}

- (void) requestMatch
{
    if (!_delegate)
    {
        NSLog(@"Error: Expected but did not find delegate");
        return;
    }
    
    GKMatchRequest *request = [self buildMatchRequest];
    
    GKTurnBasedMatchmakerViewController *viewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    viewController.turnBasedMatchmakerDelegate = self;
    viewController.showExistingMatches = YES;
    [_delegate presentViewController:viewController animated:YES completion:nil];
}

// User selected match
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *) match
{
    if (viewController)
        [_delegate dismissViewControllerAnimated:YES completion:nil];
    
    // Add match to matches
    MatchHelper *helper = [MatchHelper helperForMatch:match];
    _matchDictionary[match.matchID] = helper;
    [helper loadData];
    [helper loadParticipants];

    // Set this match to the current match
    [_delegate chooseMatch:helper];
}

#pragma mark - Invitation
- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite
{
    NSLog(@"Invitation received");
    GKMatchRequest *request = [self buildMatchRequest];
    request.playersToInvite = playersToInvite;
    GKTurnBasedMatchmakerViewController *viewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    viewController.showExistingMatches = NO;
    viewController.turnBasedMatchmakerDelegate = self;
    [_delegate presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Matchmaking Failures
// Game Center Fail
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [_delegate dismissViewControllerAnimated:YES completion:^(){
        alert(@"Error creating match: %@", error.localizedDescription);
    }];
}

// User cancel
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [_delegate dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Ending Matches
// Quit through GUI -- Must be in matchmaker one
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *) match
{
    if (viewController)
        [_delegate dismissViewControllerAnimated:YES completion:nil];
    MatchHelper *helper = _matchDictionary[match.matchID];
    [helper quitMatch];
}

- (void)handleMatchEnded:(GKTurnBasedMatch *) match
{
    MatchHelper *helper = _matchDictionary[match.matchID];
    [_delegate takeTurn:helper];
}

#pragma mark - Load from Game Center
- (void) listMatches
{
    NSLog(@"Number of Matches: %d", _matchDictionary.allKeys.count);
    for (MatchHelper *helper in _matchDictionary.allValues)
        [helper listMatch];
}

- (void) loadMatchesWithCompletion: (CompletionBlock) completion
{
    if (!_matchDictionary)
        _matchDictionary = [NSMutableDictionary dictionary];
    
    NSLog(@"Loading matches from Game Center");
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *theMatches, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error retrieving matches: %@", error.localizedDescription);
             return;
         }
         
         NSLog(@"Number of matches: %d", theMatches.count);
         for (GKTurnBasedMatch *match in theMatches)
         {
             MatchHelper *helper = [MatchHelper helperForMatch:match];
             _matchDictionary[match.matchID] = helper;
             [helper loadData];
             [helper loadParticipants];
         }
         
         [[NSOperationQueue mainQueue] addOperationWithBlock:^()
          {
              if (completion)
                  completion();
          }];
     }];
}

#pragma mark - Gameplay
- (void)handleTurnEventForMatch:(GKTurnBasedMatch *) match
                didBecomeActive:(BOOL)didBecomeActive
{
    MatchHelper *helper = [self matchForID:match.matchID];
    helper.didBecomeActive = didBecomeActive;
    
    [helper loadDataWithCompletion:^(BOOL success) {
        if (!success) return;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^()
         {
             [_delegate takeTurn:helper];
         }];
    }];
}

#pragma mark - Armageddon
- (void) removeAllMatches
{
    // This is nuclear armageddon. Prepare!
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:
     ^(NSArray *matches, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error loading matches: %@", error.localizedFailureReason);
             return;
         }
         
         NSLog(@"Attempting to remove %d matches", matches.count);
         for (MatchHelper *helper in _matchDictionary.allValues)
         {
             GKTurnBasedMatch *aMatch = helper.match;
             GKTurnBasedParticipant *me = myParticipantForMatch(aMatch);
             if (me && (me.status == GKTurnBasedParticipantStatusActive))
             {
                 NSLog(@"Quitting match %@", aMatch.matchID);
                 [helper quitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit];
                 sleep(1);
                 NSLog(@"Removing Match %@", aMatch.matchID);
                 [_matchDictionary removeObjectForKey:aMatch.matchID];
                 [helper removeFromGameCenter];
             }
             else
             {
                 NSLog(@"Removing Match %@", aMatch.matchID);
                 [_matchDictionary removeObjectForKey:aMatch.matchID];
                 [helper removeFromGameCenter];
             }
         }
     }];
}

- (void) removeMatch: (MatchHelper *) match
{
    [_matchDictionary removeObjectForKey:match.matchID];
    [match removeFromGameCenter];
}
@end