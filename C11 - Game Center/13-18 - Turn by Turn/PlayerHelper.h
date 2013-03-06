/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Utility.h"

typedef void (^CompletionBlock)();
typedef void (^SuccessBlock)(BOOL success);

// Equality
BOOL playerEqual(GKPlayer *p1, GKPlayer *p2);
BOOL playerIDCheck(GKPlayer *p1, NSString *playerID);

// My Player
BOOL myCurrentPlayerForMatch(GKTurnBasedMatch *aMatch);
GKTurnBasedParticipant *myParticipantForMatch(GKTurnBasedMatch *aMatch);
GKPlayer *me();

// Participant
NSString *participantStatus(GKTurnBasedParticipantStatus status);
NSString *partcipantSummary(GKTurnBasedParticipant *participant);

// Player Lookup
void requestPlayerForIdentifierWithCompletion(NSString *playerID, SuccessBlock completion);
void requestPlayerForIdentifier(NSString *playerID);
GKPlayer *playerWithIdentifier(NSString *playerID);
NSString *playerName(NSString *playerID);
void storePlayer(GKPlayer *player);

// Photo Lookup
void requestPlayerPhotoWithCompletion(GKPlayer *player, GKPhotoSize size, SuccessBlock completion);
void requestPhotoForPlayer(GKPlayer *player, GKPhotoSize size);
UIImage *playerPhoto(GKPlayer *player);