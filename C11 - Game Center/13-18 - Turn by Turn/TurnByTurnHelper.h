/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "MatchHelper.h"
#import "PlayerHelper.h"

@protocol MatchDelegate <NSObject>
- (void) chooseMatch: (MatchHelper *) match;
- (void) takeTurn: (MatchHelper *) match;
@end

@interface TurnByTurnHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, GKTurnBasedEventHandlerDelegate>

@property (nonatomic, weak) UIViewController <MatchDelegate> *delegate;;
@property (nonatomic, readonly) NSMutableDictionary *matchDictionary;
@property (nonatomic, readonly) NSArray *matches;

- (void) loadMatchesWithCompletion: (CompletionBlock) completion;
- (void) listMatches;
- (void) requestMatch;

// Utility
- (MatchHelper *) matchForID: (NSString *) matchID;
- (void) removeAllMatches;
- (void) removeMatch: (MatchHelper *) match;
@end