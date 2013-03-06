/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utility.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TestBedViewController : UIViewController <MPMediaPickerControllerDelegate, UIPopoverControllerDelegate>
@end

@implementation TestBedViewController
{
    UIPopoverController *popover;
    UIToolbar *toolbar;
	UIImageView *imageView;
	MPMediaItemCollection *songs;
}

#pragma mark - Utility
- (void) performDismiss
{
    if (IS_IPHONE)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [popover dismissPopoverAnimated:YES];
}

- (void) presentViewController:(UIViewController *)viewControllerToPresent
{
    if (IS_IPHONE)
	{
        [self presentViewController:viewControllerToPresent animated:YES completion:nil];
	}
	else
	{
        self.navigationItem.rightBarButtonItem.enabled = NO;
        popover = [[UIPopoverController alloc] initWithContentViewController:viewControllerToPresent];
        popover.delegate = self;
        [popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

// Popover was dismissed
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController
{
    popover = nil;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

# pragma mark TOOLBAR CONTENTS
- (NSArray *) playItems
{
	NSMutableArray *items = [NSMutableArray array];
	
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemRewind, @selector(rewind))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemPlay, @selector(play))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFastForward, @selector(fastforward))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	
	return items;
}

- (NSArray *) pauseItems
{
	NSMutableArray *items = [NSMutableArray array];
	
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemRewind, @selector(rewind))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemPause, @selector(pause))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFastForward, @selector(fastforward))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	
	return items;
}

#pragma mark PLAYBACK
#define PLAYER [MPMusicPlayerController iPodMusicPlayer]
- (void) pause
{
	[PLAYER pause];
	toolbar.items = [self playItems];
}

- (void) play
{
	[PLAYER play];
	toolbar.items = [self pauseItems];
}

- (void) fastforward
{
	[PLAYER skipToNextItem];
}

- (void) rewind
{
	[PLAYER skipToPreviousItem];
}

#pragma mark STATE CHANGES
- (void) playbackItemChanged: (NSNotification *) notification
{
	// update title and artwork
	self.title = [PLAYER.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
	MPMediaItemArtwork *artwork = [PLAYER.nowPlayingItem valueForProperty: MPMediaItemPropertyArtwork];
	imageView.image = [artwork imageWithSize:[imageView frame].size];
}

- (void) playbackStateChanged: (NSNotification *) notification
{
	// On stop, clear title, toolbar, artwork
	if (PLAYER.playbackState == MPMusicPlaybackStateStopped)
	{
		self.title = nil;
		toolbar.items = nil;
		imageView.image = nil;
	}
}

#pragma mark Media Picker
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
	songs = mediaItemCollection;
	[PLAYER setQueueWithItemCollection:songs];
	[toolbar setItems:[self playItems]];
    [self performDismiss];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self performDismiss];
}

- (void) pick
{
	MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
	mpc.delegate = self;
	mpc.prompt = @"Please select an item";
	mpc.allowsPickingMultipleItems = YES;
    [self presentViewController:mpc];
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
#if TARGET_IPHONE_SIMULATOR
    self.title = @"Recipe requires device";
#else
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pick));
    toolbar = [[UIToolbar alloc] init];
    [self.view addSubview:toolbar];
    PREPCONSTRAINTS(toolbar);
    STRETCH_VIEW_H(self.view, toolbar);
    CONSTRAIN(self.view, toolbar, @"V:[toolbar]|");
    
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    PREPCONSTRAINTS(imageView);
    
    STRETCH_VIEW_H(self.view, imageView);
    CONSTRAIN(self.view, imageView, @"V:|-[imageView]-49-|");
    
    // Stop any ongoing music
	[PLAYER stop];
	
	// Add listeners
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:PLAYER];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackItemChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:PLAYER];
	[PLAYER beginGeneratingPlaybackNotifications];
#endif
}
@end

#pragma mark -

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
    [[UIToolbar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
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