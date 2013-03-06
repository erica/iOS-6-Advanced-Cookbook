//
//  TestBedSuperViewController.h
//  HelloWorld
//
//  Created by Erica Sadun on 10/31/12.
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ModalAlertDelegate.h"
#import "Utility.h"

@interface TestBedSuperViewController : UIViewController <GKMatchDelegate, GKMatchmakerViewControllerDelegate>
@property (nonatomic, readonly) NSString *opponentName;
@property (nonatomic, readonly) GKMatch *match;
@property (nonatomic, readonly) BOOL matchStarted;
- (void) setPrematchGUI;
- (void) activateGameGUI;
@end

