/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "MatchHelper.h"
#import "Utility.h"

#pragma mark - Utility

BOOL matchEqual(GKTurnBasedMatch *m1, GKTurnBasedMatch *m2)
{
    return [m1.matchID isEqualToString:m2.matchID];
}

BOOL matchIDCheck(GKTurnBasedMatch *m1, NSString *matchID)
{
    return [m1.matchID isEqualToString:matchID];
}

//enum {
//    GKTurnBasedMatchStatusUnknown = 0,
//    GKTurnBasedMatchStatusOpen = 1,
//    GKTurnBasedMatchStatusEnded = 2,
//    GKTurnBasedMatchStatusMatching = 3
//};
//typedef NSInteger GKTurnBasedMatchStatus;

NSString *statusName(GKTurnBasedMatchStatus status)
{
    switch (status)
    {
        case GKTurnBasedMatchStatusOpen:
            return @"Open";
        case GKTurnBasedMatchStatusEnded:
            return @"Ended";
        case GKTurnBasedMatchStatusMatching:
            return @"Matching";
        case GKTurnBasedMatchStatusUnknown:
        default:
            return @"Unknown";
    }
}

#pragma mark - Helper

@implementation MatchHelper
- (instancetype) initWithMatch: (GKTurnBasedMatch *) match
{
    if (!(self = [super init])) return self;
    
    _match = match;
    
    return self;
}

+ (instancetype) helperForMatch: (GKTurnBasedMatch *) match
{
    MatchHelper *helper = [[self alloc] initWithMatch:match];
    return helper;
}

#pragma mark - Expose match
- (NSString *) matchID
{
    return _match.matchID;
}

- (GKTurnBasedParticipant *) currentParticipant
{
    return _match.currentParticipant;
}

- (NSString *) currentParticipantName
{
    if (!_match.currentParticipant.playerID)
        return _match.currentParticipant.description;
    return playerName(_match.currentParticipant.playerID);
}

- (NSArray *) participants
{
    return _match.participants;
}

- (GKTurnBasedMatchStatus) status
{
    return _match.status;
}

- (NSString *) statusString
{
    return statusName(_match.status);
}

- (NSDate *) creationDate
{
    return _match.creationDate;
}

- (BOOL) isMyTurn
{
    return myCurrentPlayerForMatch(_match);
}

- (BOOL) amActive
{
    GKTurnBasedParticipant *me = myParticipantForMatch(_match);
    return (me.status == GKTurnBasedParticipantStatusActive);
}

- (BOOL) matchIsDone
{
    if (_match.status == GKTurnBasedMatchStatusEnded)
        return YES;
    
    // Note -- this assumes "done for one is done for all"
    for (GKTurnBasedParticipant *participant in _match.participants)
    {
        if (participant.status == GKTurnBasedParticipantStatusDone)
            return YES;
    }
    
    return NO;
}

- (void) listMatch
{
    NSLog(@"Match %@ : %@", self.matchID, self.statusString);
    NSLog(@"    %d players (%d active)", self.participants.count, self.activeParticipantCount);
    NSLog(@"Current Player: %@", self.currentParticipantName);
    [self listParticipants];
}

#pragma mark - Match Data
- (id) object
{
    NSData *data = _data;
    if (!data)
        return nil;
    
    if (data.length == 0)
        return nil;
    
    NSError *error;
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!result)
        NSLog(@"Error converting data to JSON object: %@", error.localizedDescription);

    return result;
}

- (void) setObject: (id) object
{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (!data)
    {
        NSLog(@"Error converting object to JSON data: %@", error.localizedDescription);
        return;
    }

    _data = data;
}

- (void) loadDataWithCompletion: (SuccessBlock) completion
{
    [_match loadMatchDataWithCompletionHandler:
     ^(NSData *matchData, NSError *error)
     {
         if (error)
         {
             NSLog(@"Could not retrieve match data for Match %@: %@", _match.matchID, error.localizedDescription);
         }
         else if (!matchData)
         {
             NSLog(@"No data returned for Match %@", _match.matchID);
             return;
         }
         else
             _data = matchData;
         
         [[NSOperationQueue mainQueue] addOperationWithBlock:^()
          {
              if (completion)
                  completion((error == nil) && (matchData != nil));
          }];
     }];
}

- (void) loadData
{
    [self loadDataWithCompletion:nil];
}

#pragma mark - Participants
// Count participants in match
- (NSInteger) activeParticipantCount
{
    NSInteger count = 0;
    for (GKTurnBasedParticipant *participant in _match.participants)
    {
        if (participant.status == GKTurnBasedParticipantStatusActive)
            count++;
    }
    return count;
}

- (NSArray *) otherCurrentParticipants
{
    // Determine who's left
    NSMutableArray *participants = [NSMutableArray arrayWithArray:_match.participants];
    
    // Remove self
    GKTurnBasedParticipant *myParticipant = myParticipantForMatch(_match);
    if (myParticipant)
        [participants removeObject:myParticipant];
    
    // Remove all null participants
    for (GKTurnBasedParticipant *participant in participants)
    {
        if (!participant.playerID)
            [participants removeObject:participant];
    }

    return participants;
}

- (NSArray *) participantIDs
{
    NSMutableArray *array = [NSMutableArray array];
    if (!_match.participants)
        return array;

    for (GKTurnBasedParticipant *participant in _match.participants)
    {
        // Only add real participants who have joined
        if (participant.playerID)
            [array addObject:participant.playerID];
    }

    return array;
}

- (void) listParticipants
{
    int count = 1;
    for (GKTurnBasedParticipant *participant in _match.participants)
        NSLog(@"%4d. %@", count++, partcipantSummary(participant));
}

- (void) loadParticipants
{
    for (GKTurnBasedParticipant *participant in _match.participants)
    {
        if (participant.playerID)
            requestPlayerForIdentifier(participant.playerID);
    }
}

#pragma mark - Turn by Turn

//extern NSTimeInterval GKTurnTimeoutDefault;
//extern NSTimeInterval GKTurnTimeoutNone;

- (void) endTurnWithTimeout: (NSTimeInterval) timeout withCompletion: (SuccessBlock) completion
{
    if (!myCurrentPlayerForMatch(_match))
    {
        NSLog(@"Error: You are not current player for match %@", _match.matchID);
        return;
    }

    NSMutableArray *participants = [NSMutableArray arrayWithArray:_match.participants];
    GKTurnBasedParticipant *me = myParticipantForMatch(_match);
    [participants removeObject:me];

    [_match endTurnWithNextParticipants:participants
                            turnTimeout:timeout
                              matchData:_data
                      completionHandler:^(NSError *error)
     {
         if (error)
             NSLog(@"Error completing turn: %@", error.localizedDescription);

         [[NSOperationQueue mainQueue] addOperationWithBlock:^()
          {
              if (completion)
                  completion(error == nil);
          }];
     }];
}

- (void) endTurnWithCompletion: (SuccessBlock) completion
{
    [self endTurnWithTimeout:GKTurnTimeoutDefault withCompletion:completion];
}

- (void) endTurn
{
    [self endTurnWithCompletion:nil];
}

#pragma mark - Match Completion
//enum {
//    GKTurnBasedMatchOutcomeNone = 0,
//    GKTurnBasedMatchOutcomeQuit = 1,
//    GKTurnBasedMatchOutcomeWon = 2,
//    GKTurnBasedMatchOutcomeLost = 3,
//    GKTurnBasedMatchOutcomeTied = 4,
//    GKTurnBasedMatchOutcomeTimeExpired = 5,
//    GKTurnBasedMatchOutcomeFirst = 6,
//    GKTurnBasedMatchOutcomeSecond = 7,
//    GKTurnBasedMatchOutcomeThird = 8,
//    GKTurnBasedMatchOutcomeFourth = 9,
//    GKTurnBasedMatchOutcomeCustomRange = 0x00FF0000
//};
//typedef NSInteger GKTurnBasedMatchOutcome;

- (void) quitOutOfTurnWithOutcome: (GKTurnBasedMatchOutcome) outcome
{
    GKTurnBasedParticipant *participant = myParticipantForMatch(_match);
    participant.matchOutcome = outcome;

    [_match participantQuitOutOfTurnWithOutcome:outcome
                          withCompletionHandler:^(NSError *error)
     {
         if (error)
             NSLog(@"Error while quitting match out of turn %@: %@", _match.matchID, error.localizedDescription);
         else
             NSLog(@"Participant quit match out of turn: %@", _match.matchID);
     }];
}

// Finish the game
- (void) finishMatchWithOutcome: (GKTurnBasedMatchOutcome) outcome
{
    GKTurnBasedParticipant *participant = myParticipantForMatch(_match);
    if (!participant)
    {
        NSLog(@"Error: Cannot finish game. You are not playing in match %@.", _match.matchID);
        return;
    }

    participant.matchOutcome = outcome;
    
    NSArray *participants = self.otherCurrentParticipants;
    BOOL isCurrent = myCurrentPlayerForMatch(_match);
    
    if ((participants.count == 0) || !isCurrent)
    {
        // no other valid players or out of turn
        [self quitOutOfTurnWithOutcome:outcome];
        return;
    }

    [_match participantQuitInTurnWithOutcome:outcome
                            nextParticipants:participants
                                 turnTimeout:GKTurnTimeoutNone
                                   matchData:_data
                           completionHandler:^(NSError *error)
     {
         if (error)
             NSLog(@"Error while quitting match %@ in turn: %@", _match.matchID, error.localizedDescription);
         else
             NSLog(@"Participant did quit in turn");
     }];
}

// You quit the game
- (void) quitMatch
{
    [self finishMatchWithOutcome:GKTurnBasedMatchOutcomeQuit];
}

// You win the game
- (void) winMatch
{
    [self finishMatchWithOutcome:GKTurnBasedMatchOutcomeWon];
}

// You lose the game
- (void) loseMatch
{
    [self finishMatchWithOutcome:GKTurnBasedMatchOutcomeLost];
}


#pragma mark - Game Center
- (void) removeFromGameCenter
{
    [_match removeWithCompletionHandler:^(NSError * error)
     {
         if (error)
         {
             NSLog(@"Error removing match %@: %@", _match.matchID, error.localizedDescription);
             return;
         }
         
         NSLog(@"Match %@ removed from Game Center", _match.matchID);
         _terminated = YES;
     }];
}
@end