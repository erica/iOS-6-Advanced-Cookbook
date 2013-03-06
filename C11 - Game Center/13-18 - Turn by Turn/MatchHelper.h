/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "PlayerHelper.h"

BOOL matchEqual(GKTurnBasedMatch *m1, GKTurnBasedMatch *m2);
BOOL matchIDCheck(GKTurnBasedMatch *m1, NSString *matchID);

NSString *statusName(GKTurnBasedMatchStatus status);

@interface MatchHelper : NSObject
- (instancetype) initWithMatch: (GKTurnBasedMatch *) match;
+ (instancetype) helperForMatch: (GKTurnBasedMatch *) match;

@property (nonatomic, readonly) GKTurnBasedMatch *match;

// Data
@property (nonatomic, strong) NSData *data;
@property (nonatomic) id object;
- (void) loadData;
- (void) loadDataWithCompletion: (SuccessBlock) completion;

// Exposing Match properties
@property (nonatomic, readonly) NSString *matchID;
@property (nonatomic, readonly) GKTurnBasedParticipant *currentParticipant;
@property (nonatomic, readonly) NSString *currentParticipantName;
@property (nonatomic, readonly) NSArray *participants;
@property (nonatomic, readonly) GKTurnBasedMatchStatus status;
@property (nonatomic, readonly) NSString *statusString;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) BOOL isMyTurn;
@property (nonatomic, readonly) BOOL amActive;
@property (nonatomic, readonly) BOOL matchIsDone;

// Debug
- (void) listMatch;

// Participants
@property (nonatomic, readonly) NSInteger activeParticipantCount;
@property (nonatomic, readonly) NSArray *otherCurrentParticipants;
@property (nonatomic, readonly) NSArray *participantIDs;
- (void) listParticipants;
- (void) loadParticipants;

// Turn by Turn
@property (nonatomic) BOOL didBecomeActive;
- (void) endTurn;
- (void) endTurnWithCompletion: (SuccessBlock) completion;
- (void) endTurnWithTimeout: (NSTimeInterval) timeout withCompletion: (SuccessBlock) completion;

// Completion
- (void) quitOutOfTurnWithOutcome: (GKTurnBasedMatchOutcome) outcome;
- (void) finishMatchWithOutcome: (GKTurnBasedMatchOutcome) outcome;
- (void) quitMatch;
- (void) winMatch;
- (void) loseMatch;

// Game Center
- (void) removeFromGameCenter;
@property (nonatomic, readonly) BOOL terminated;
@end