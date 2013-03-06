/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Utility.h"
#import "ModalSheetDelegate.h"

@interface TestBedViewController : UIViewController <AVAudioPlayerDelegate>
@end

@implementation TestBedViewController
{
    IBOutlet UIView *controlView;
    
    // Outlets
	IBOutlet UIProgressView *meter1;
	IBOutlet UIProgressView *meter2;
	IBOutlet UISlider *scrubber;
	IBOutlet UISlider *volumeSlider;
	IBOutlet UILabel *nowPlaying;
    
    // Player
    AVAudioPlayer *player;
	NSTimer *timer;
	NSString *path;
}

- (void) viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Select Audio", @selector(pick:));
    
    [self.view addSubview:controlView];
	path = [[NSBundle mainBundle] pathForResource:@"ARB" ofType:@"mp3"];
    
    PREPCONSTRAINTS(controlView);
    STRETCH_VIEW(self.view, controlView);
}

// Pretty time
- (NSString *) formatTime: (int) numberOfSeconds
{
	int secs = numberOfSeconds % 60;
	int min = numberOfSeconds / 60;
	return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}

// Set the meters to the current peak and average power
- (void) updateMeters
{
    // Retrieve current values
	[player updateMeters];
    
    // Show average and peak values on the two meters
	meter1.progress = pow(10, 0.05f * [player averagePowerForChannel:0]);
	meter2.progress = pow(10, 0.05f * [player peakPowerForChannel:0]);
    
    // And on the scrubber
    scrubber.value = (player.currentTime / player.duration);
    
    // Display the current playback progress in minutes and seconds
	self.title = [NSString stringWithFormat:@"%@ of %@", [self formatTime:player.currentTime], [self formatTime:player.duration]];
}

// Pause playback
- (void) pause: (id) sender
{
	if (player)
        [player pause];
    
    // Update the play/pause button
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPlay, @selector(play:));
    
    // Disable interactive elements
	meter1.progress = 0.0f;
	meter2.progress = 0.0f;
	volumeSlider.enabled = NO;
	scrubber.enabled = NO;
    
    // Stop listening for meter updates
	[timer invalidate];
}

// Start or resume playback
- (void) play: (id) sender
{
	if (player)
        [player play];
    
    // Enable the interactive elements
	volumeSlider.value = player.volume;
	volumeSlider.enabled = YES;
	scrubber.enabled = YES;
	
    // Update the play/pause button
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, @selector(pause:));
    
    // Start listening for meter updates
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    
}

// Update the volume
- (IBAction) setVolume: (id) sender
{
	if (player) player.volume = volumeSlider.value;
}

// Catch the end of the scrubbing
- (IBAction) scrubbingDone: (id) sender
{
	[self play:nil];
}

// Update playback point during scrubs
- (IBAction) scrub: (id) sender
{
	// Pause the player -- optional
	// [player pause];
    // self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPlay, @selector(play:));
	
	// Calculate the new current time
	player.currentTime = scrubber.value * player.duration;
	
	// Update the title, nav bar
	self.title = [NSString stringWithFormat:@"%@ of %@", [self formatTime:player.currentTime], [self formatTime:player.duration]];
}

// Prepare but do not play audio
- (BOOL) prepAudio
{
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;
    
	// Establish player
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
	if (!player)
	{
		NSLog(@"AVAudioPlayer could not be established: %@", error.localizedFailureReason);
		return NO;
	}
	
	[player prepareToPlay];
	player.meteringEnabled = YES;
	player.delegate = self;
    
    // Initialize GUI
    meter1.progress = 0.0f;
	meter2.progress = 0.0f;
    self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPlay, @selector(play:));
	scrubber.enabled = NO;
	
	return YES;
}

// On finishing, return to quiescent state
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	self.navigationItem.leftBarButtonItem = nil;
	scrubber.value = 0.0f;
	scrubber.enabled = NO;
	volumeSlider.enabled = NO;
	[self prepAudio];
}

// Select a media file
- (void) pick: (UIBarButtonItem *) sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
	// Each of these media files is in the public domain via archive.org
	NSArray *choices = [@"Alexander's Ragtime Band*Hello My Baby*Ragtime Echoes*Rhapsody In Blue*A Tisket A Tasket*In the Mood" componentsSeparatedByString:@"*"];
	NSArray *media = [@"ARB-AJ*HMB1936*ragtime*RhapsodyInBlue*Tisket*InTheMood" componentsSeparatedByString:@"*"];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Musical selections" delegate:nil cancelButtonTitle:IS_IPAD ? nil : @"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *choice in choices)
        [actionSheet addButtonWithTitle:choice];
    
    ModalSheetDelegate *msd = [ModalSheetDelegate delegateWithSheet:actionSheet];
    actionSheet.delegate = msd;
    
    int answer = [msd showFromBarButtonItem:sender animated:YES];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (IS_IPAD)
    {
        if (answer == -1) return; // cancel
        if (answer >= choices.count)
            return;
    }
    else
    {
        if (answer == 0) return; // cancel
        if (answer > choices.count)
            return;
        answer--;
    }
    
    // no action, if already playing
    if ([nowPlaying.text isEqualToString:[choices objectAtIndex:answer]])
        return;
    
    // stop any current item
    if (player)
        [player stop];
    
    // Load in the new audio and play it
	path = [[NSBundle mainBundle] pathForResource:[media objectAtIndex:answer] ofType:@"mp3"];
    nowPlaying.text = [choices objectAtIndex:answer];
	[self prepAudio];
    [self play:nil];
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