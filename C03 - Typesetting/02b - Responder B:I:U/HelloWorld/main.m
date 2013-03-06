/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController <UITextViewDelegate>
{
    UITextView *textView;
    NSString *lorem;
}
@end

@implementation TestBedViewController
- (void) setupToolbar
{
    UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)];
    RESIZABLE(tb);
    
    NSMutableArray *items = [NSMutableArray array];
    
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
    
    while (textView.undoManager.isRedoing) ;
    while (textView.undoManager.isUndoing) ;
    
	BOOL canUndo = [textView.undoManager canUndo];
    UIBarButtonItem *undoItem = SYSBARBUTTON_TARGET(UIBarButtonSystemItemUndo, textView.undoManager, @selector(undo));
    undoItem.enabled = canUndo;
    [items addObject:undoItem];
    
	BOOL canRedo = [textView.undoManager canRedo];
    UIBarButtonItem *redoItem = SYSBARBUTTON_TARGET(UIBarButtonSystemItemRedo, textView.undoManager, @selector(redo));
    redoItem.enabled = canRedo;
    [items addObject:redoItem];
    
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
    
    tb.items = items;
    self.navigationItem.titleView = tb;
}

- (void) initializeText
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 12.0f;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Futura" size:24.0f];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:lorem attributes: attributes];
    textView.attributedText = attributedString;
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setupToolbar) userInfo:nil repeats:YES];
}

- (BOOL)canBecomeFirstResponder {return YES;}
- (void)viewDidAppear:(BOOL)animated {[self becomeFirstResponder];}
- (void)viewWillDisappear:(BOOL)animated {[self resignFirstResponder];}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];    
    
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.delegate = self;
    textView.allowsEditingTextAttributes = YES;

    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    
    lorem = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis eleifend risus id arcu volutpat porta. Cras vel dolor nec lectus iaculis luctus. Sed mollis, ante at bibendum pulvinar, purus dui pellentesque ipsum, quis pulvinar diam nisl in massa. Curabitur varius malesuada suscipit.\nPhasellus dictum, mi a rhoncus convallis, sapien nulla venenatis nisl, id consectetur tellus dui et est. Nullam tempor dapibus diam. Pellentesque urna enim, viverra et fringilla nec, lobortis non libero. Morbi sit amet erat sit amet lacus tempus venenatis vitae nec nulla.";

    [self initializeText];
    [self setupToolbar];
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