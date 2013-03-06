
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "GameKitHelper.h"

@implementation GameKitHelper
{
    GKPeerPickerController *picker;
}

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

// Simple Alert Utility
void showAlert(id formatstring,...)
{
	if (!formatstring) return;

	va_list arglist;
	va_start(arglist, formatstring);
        id outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"Okay"otherButtonTitles:nil];
	[alertView show];
}

#pragma mark Data Sharing
- (void) sendData: (NSData *) data
{
	NSError *error;
	BOOL didSend = [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
	if (!didSend)
		NSLog(@"Error sending data to peers: %@", error.localizedFailureReason);
    SAFE_PERFORM_WITH_ARG(_dataDelegate, @selector(sentData:), (didSend ? nil : error.localizedFailureReason));
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    SAFE_PERFORM_WITH_ARG(_dataDelegate, @selector(receivedData:), data);
}

#pragma mark Connections
- (void) connect
{
	if (!_isConnected)
	{
		picker = [[GKPeerPickerController alloc] init];
		picker.delegate = self; 
		picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
		[picker show];
        _dataDelegate.navigationItem.rightBarButtonItem = nil;
	}
}

- (void) setupConnectButton
{
    _dataDelegate.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(connect));
    _dataDelegate.navigationItem.rightBarButtonItem.enabled = YES;
}

// Dismiss the peer picker on cancel
- (void) peerPickerControllerDidCancel: (GKPeerPickerController *) aPicker
{
    picker = nil;
    [self setupConnectButton];
}

- (void)peerPickerController:(GKPeerPickerController *) aPicker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
	[_session setDataReceiveHandler:self withContext:nil];
	_isConnected = YES;
    SAFE_PERFORM_WITH_ARG(_dataDelegate, @selector(connectionEstablished), nil);
    
    if (picker)
    {
        [picker dismiss];
        picker = nil;
    }
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type 
{
    NSLog(@"Requesting session");
    
	// The session ID is basically the name of the service, and is used to create the bonjour connection.
    if (!_session)
    { 
        _session = [[GKSession alloc] initWithSessionID:(self.sessionID ? self.sessionID : @"Sample Session") displayName:nil sessionMode:GKSessionModePeer]; 
        _session.delegate = self; 
    } 
	return _session;
}

#pragma mark Session Handling
- (void) disconnect
{
    _dataDelegate.navigationItem.rightBarButtonItem.enabled = NO;
	[_session disconnectFromAllPeers];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	/* STATES: GKPeerStateAvailable, = 0,  GKPeerStateUnavailable, = 1,  GKPeerStateConnected, = 2, 
	   GKPeerStateDisconnected, = 3, GKPeerStateConnecting = 4 */
	
	NSArray *states = [NSArray arrayWithObjects:@"Available", @"Unavailable", @"Connected", @"Disconnected", @"Connecting", nil];
	NSLog(@"Peer state is now %@", [states objectAtIndex:state]);
    
    if (picker && (state == GKPeerStateConnected))
    {
        [picker dismiss];
        picker = nil;
    }
	
    if (state == GKPeerStateConnected)
    {
        _dataDelegate.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(disconnect));
        _dataDelegate.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if (state == GKPeerStateDisconnected)
    {
        _isConnected = NO;
        _session = nil;
        showAlert(@"Lost connection with peer. You are no longer connected to another device.");
        [self disconnect];
        [self setupConnectButton];
        SAFE_PERFORM_WITH_ARG(_dataDelegate, @selector(connectionLost), nil);
    }
    else if (state == GKPeerStateAvailable)
    {
        _dataDelegate.navigationItem.rightBarButtonItem = BARBUTTON(@"Peer Available", nil);
        _dataDelegate.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else if (state == GKPeerStateUnavailable)
    {
        _dataDelegate.navigationItem.rightBarButtonItem = BARBUTTON(@"Peer Unavailable", nil);
        _dataDelegate.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else if (state == GKPeerStateConnecting)
    {
        _dataDelegate.navigationItem.rightBarButtonItem = BARBUTTON(@"Connecting...", nil);
        _dataDelegate.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

+ (id) helperWithSessionName: (NSString *) name delegate: (UIViewController <GameKitHelperDataDelegate> *) delegate
{
    GameKitHelper *helper = [[GameKitHelper alloc] init];
    helper.sessionID = name;
    helper.dataDelegate = delegate;
    [helper setupConnectButton];

    return helper;
}
@end