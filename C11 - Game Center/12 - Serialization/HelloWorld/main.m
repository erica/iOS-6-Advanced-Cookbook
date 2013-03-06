/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "TestBedSuperViewController.h"

#define GKROLLFORFIRST  @"Roll for First"
#define GKROLLDIE       @"Roll Die"

@interface TestBedViewController : TestBedSuperViewController
@end

@implementation TestBedViewController
{
    BOOL startupResolved;
    BOOL opponentGoesFirst;
    
    NSNumber *localRoll;
    NSNumber *remoteRoll;
    
    UIImageView *myDiceView;
    UIImageView *theirDiceView;
}

#pragma mark - Utility

- (UIImage *) dieWithValue: (int) value ownDie: (BOOL) isSelf
{
    CGSize size = CGSizeMake(100.0f, 100.0f);
    CGRect rect = (CGRect){.size = size};
    
    UIGraphicsBeginImageContext(size);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:16.0f];
    path.lineWidth = 3.0f;
    
    UIColor *blueColor = [[UIColor blueColor] colorWithAlphaComponent:0.25f];
    UIColor *greenColor = [[UIColor greenColor] colorWithAlphaComponent:0.25f];
    [(isSelf ? greenColor : blueColor) set];
    [path fill];

    [[UIColor blackColor] set];
    [path stroke];

    NSString *string = @(value).stringValue;
    if (value == 0) string = @"?";
    
    UIFont *font = [UIFont fontWithName:@"Futura" size:24.0f];
    CGSize layoutSize = [string sizeWithFont:font];
    CGRect inset = CGRectInset(rect, (size.width - layoutSize.width) / 2.0f, (size.height - layoutSize.height) / 2.0f);
    [string drawInRect:inset withFont:font];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - View Setup

- (void) loadView
{
    [super loadView];
    myDiceView = [[UIImageView alloc] init];
    theirDiceView = [[UIImageView alloc] init];
    
    [self.view addSubview:myDiceView];
    [self.view addSubview:theirDiceView];
    
    PREPCONSTRAINTS(myDiceView);
    PREPCONSTRAINTS(theirDiceView);
    
    CONSTRAIN(self.view, myDiceView, @"H:|-[myDiceView(==100)]");
    CONSTRAIN(self.view, theirDiceView, @"H:[theirDiceView(==100)]-|");
    CONSTRAIN(self.view, theirDiceView, @"V:|-[theirDiceView(==100)]");
    CONSTRAIN(self.view, myDiceView, @"V:|-[myDiceView(==100)]");
    
    myDiceView.image = [self dieWithValue:0 ownDie:YES];
    theirDiceView.image = [self dieWithValue:0 ownDie:NO];
    
    self.navigationItem.leftBarButtonItem = BARBUTTON(GKROLLDIE, @selector(rollMyDie));
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void) setPrematchGUI
{
    [super setPrematchGUI];
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void) activateGameGUI
{
    startupResolved = NO;
    [super activateGameGUI];
    [self sendRoll:GKROLLFORFIRST];
    [self checkStartupWinner];
}


#pragma mark - Winner Checks

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    myDiceView.image = [self dieWithValue:0 ownDie:YES];
    theirDiceView.image = [self dieWithValue:0 ownDie:NO];
}

- (void) checkStartupWinner
{
    // Already resolved the startup winner?
    if (startupResolved)
        return;
    
    if (!remoteRoll || !localRoll)
    {
        self.title = @"Waiting for Remote Roll";
        [self performSelector:@selector(checkStartupWinner) withObject:nil afterDelay:1.0f];
        return;
    }
    
    NSLog(@"Remote roll: %@, local roll: %@", remoteRoll, localRoll);
    if (localRoll.integerValue == remoteRoll.integerValue)
    {
        self.title = @"Tie. Roll again.";
        remoteRoll = nil;
        localRoll = nil;
        [self sendRoll:GKROLLFORFIRST];
        return;
    }
    
    startupResolved = YES;
    UIAlertView *alert;

    BOOL theyGo = remoteRoll.integerValue > localRoll.integerValue;

    self.navigationItem.leftBarButtonItem.enabled = !theyGo;
    opponentGoesFirst = theyGo;

    if (theyGo)
    {
        self.title = [NSString stringWithFormat:@"%@'s turn", self.opponentName];
        alert = alertView(@"You lost the toss! %@ goes first. When it is your turn, the Roll Die button will activate. Press it then.", self.opponentName);
    }
    else
    {
        alert = alertView(@"You won the toss! Tap the Roll Die button.");
        self.title = @"Your turn";
    }
    
    alert.delegate = self;
    [alert show];    
}

- (void) checkWinner
{
    if (!localRoll || !remoteRoll)
    {
        NSLog(@"Error: local or remote roll is undefined");
        return;
    }
    
    // Both rolls are in. Who won?
    NSLog(@"Remote roll: %@, local roll: %@", remoteRoll, localRoll);
    int local = localRoll.integerValue;
    int remote = remoteRoll.integerValue;
    
    UIAlertView *alert;
    if (local == remote)
    {
        alert = alertView(@"That round was a tie (%d to %d)", local, local);
    }
    else if (remoteRoll.unsignedIntValue > localRoll.unsignedIntValue)
    {
        alert = alertView(@"%@ won that round (%d to %d)", self.opponentName, remote, local);
    }
    else
    {
        alert = alertView(@"You won that round. %d beats %d", local, remote);
    }
    
    alert.delegate = self;
    [alert show];

    // Reset both values
    localRoll = nil;
    remoteRoll = nil;
    
    // Reset GUI
    self.navigationItem.leftBarButtonItem.enabled = !opponentGoesFirst;
    if (opponentGoesFirst)
        self.title = [NSString stringWithFormat:@"%@'s turn", self.opponentName];
    else
        self.title = @"Your turn";
}

#pragma mark - Roll Sending

- (void) sendRoll: (NSString *) operationType
{
    localRoll = @(random() % 100 + 1); // 1d100
    myDiceView.image = [self dieWithValue:localRoll.integerValue ownDie:YES];
    
    NSDictionary *dictionary = @{operationType:localRoll};
    NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    [self.match sendDataToAllPlayers:json withDataMode:GKMatchSendDataReliable error:nil];
}

- (void) rollMyDie
{
    // handle button press here
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self sendRoll:GKROLLDIE];
    
    if (opponentGoesFirst)
    {
        self.title = nil;
        [self checkWinner];
    }
    else
        self.title = [NSString stringWithFormat:@"%@'s turn", self.opponentName];
}

- (void)match:(GKMatch *) aMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *key = [[dict allKeys] lastObject];
    if (!key) return;
    
    NSLog(@"Received Key: %@", key);
    remoteRoll = dict[key];
    theirDiceView.image = [self dieWithValue:remoteRoll.integerValue ownDie:NO];
    
    if ([key isEqualToString:GKROLLFORFIRST])
    {
        [self checkStartupWinner];
        return;
    }
    
    if ([key isEqualToString:GKROLLDIE])
    {
        self.navigationItem.leftBarButtonItem.enabled = opponentGoesFirst;
        self.title = opponentGoesFirst ? @"Your Turn" : nil;
        if (!opponentGoesFirst)
            [self checkWinner];
    }
}
@end

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