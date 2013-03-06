/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "PlayerHelper.h"

#pragma mark - Basic Utilities

static NSMutableDictionary *playerDictionary;
static NSMutableDictionary *photoDictionary;

#pragma mark - Equality

BOOL playerEqual(GKPlayer *p1, GKPlayer *p2)
{
    return [p1.playerID isEqualToString:p2.playerID];
}

BOOL playerIDCheck(GKPlayer *p1, NSString *playerID)
{
    return [p1.playerID isEqualToString:playerID];
}

#pragma mark - My Player

BOOL myCurrentPlayerForMatch(GKTurnBasedMatch *aMatch)
{
    if (!aMatch.currentParticipant.playerID)
        return NO;
    return playerIDCheck(me(), aMatch.currentParticipant.playerID);
}

GKTurnBasedParticipant *myParticipantForMatch(GKTurnBasedMatch *aMatch)
{
    for (GKTurnBasedParticipant *eachParticipant in aMatch.participants)
        if (eachParticipant.playerID && playerIDCheck(me(), eachParticipant.playerID))
            return eachParticipant;
    return nil;
}

GKPlayer *me()
{
    return [GKLocalPlayer localPlayer];
}

#pragma mark - Participant
// Convert player status to a string description
NSString *participantStatus(GKTurnBasedParticipantStatus status)
{
    switch (status)
    {
        case GKTurnBasedParticipantStatusActive:
            return @"Active";
        case GKTurnBasedParticipantStatusDeclined:
            return @"Declined";
        case GKTurnBasedParticipantStatusDone:
            return @"Done";
        case GKTurnBasedParticipantStatusInvited:
            return @"Invited";
        case GKTurnBasedParticipantStatusMatching:
            return @"Matching";
        case GKTurnBasedParticipantStatusUnknown:
        default:
            return @"Unknown";
    }
}

NSString *partcipantSummary(GKTurnBasedParticipant *participant)
{
    if (!participant.playerID)
        return participant.description;
    
    NSString *summary = [NSString stringWithFormat:@"%@ [%@] %@",
                         participant.playerID,
                         playerName(participant.playerID),
                         participantStatus(participant.status)];
    return summary;
}

#pragma mark - Player Lookup

// Perform Asynchronous Request for Player
void requestPlayerForIdentifierWithCompletion(NSString *playerID, SuccessBlock completion)
{
    if (!playerDictionary)
        playerDictionary = [NSMutableDictionary dictionary];
    if (playerDictionary[playerID])
        return;
    
    [GKPlayer loadPlayersForIdentifiers:@[playerID] withCompletionHandler:^(NSArray *players, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error retrieving player from Game Center: %@", error.localizedDescription);
             return;
         }
         
         GKPlayer *player = [players lastObject];
         storePlayer(player);

         [[NSOperationQueue mainQueue] addOperationWithBlock:^()
          {
              if (completion)
                  completion(error == nil);
          }];
     }];
}
void requestPlayerForIdentifier(NSString *playerID)
{
    requestPlayerForIdentifierWithCompletion(playerID, nil);
}

// Return player for Player ID
GKPlayer *playerWithIdentifier(NSString *playerID)
{
    if (!playerDictionary)
        playerDictionary = [NSMutableDictionary dictionary];

    BOOL isMe = playerIDCheck(me(), playerID);
    if (isMe) return me();
    
    GKPlayer *player = playerDictionary[playerID];
    if (!player)
    {
        requestPlayerForIdentifier(playerID);
        return nil;
    }
    
    return player;
}

// Return name for Player ID
NSString *playerName(NSString *playerID)
{
    GKPlayer *player = playerWithIdentifier(playerID);
    if (player)
        return player.displayName;
    return playerID;
}

// Store Player Information
void storePlayer(GKPlayer *player)
{
    if (!playerDictionary)
        playerDictionary = [NSMutableDictionary dictionary];
    playerDictionary[player.playerID] = player;
    
    if (!photoDictionary)
        photoDictionary = [NSMutableDictionary dictionary];
    if (!photoDictionary[player.playerID])
        requestPhotoForPlayer(player, GKPhotoSizeNormal);
}

#pragma mark - Photo Lookup

//enum {
//    GKPhotoSizeSmall = 0,
//    GKPhotoSizeNormal,
//};
//typedef NSInteger GKPhotoSize;

// Perform Asynchronous Request for Photo
void requestPlayerPhotoWithCompletion(GKPlayer *player, GKPhotoSize size, SuccessBlock completion)
{
    if (!photoDictionary)
        photoDictionary = [NSMutableDictionary dictionary];
    if (photoDictionary[player.playerID])
        return;
    
    [player loadPhotoForSize:size withCompletionHandler:^(UIImage *photo, NSError *error) {
        if (error)
        {
            // Enable if you really want this feedback.
            // NSLog(@"Error retrieving player photo from Game Center: %@", error.localizedDescription);
            return;
        }
        photoDictionary[player.playerID] = photo;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^()
         {
             if (completion)
                 completion(error == nil);
         }];
    }];
}

void requestPhotoForPlayer(GKPlayer *player, GKPhotoSize size)
{
    requestPlayerPhotoWithCompletion(player, size, nil);
}

// Retrieve Photo
UIImage *playerPhoto(GKPlayer *player)
{
    if (!photoDictionary)
        photoDictionary = [NSMutableDictionary dictionary];
    
    UIImage *image = photoDictionary[player.playerID];
    if (!image)
    {
        requestPhotoForPlayer(player, GKPhotoSizeNormal);
        return nil;
    }
    
    return image;
}