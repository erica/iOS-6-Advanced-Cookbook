/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "Utility.h"

@interface TestBedViewController : UIViewController
{
    UITextView *textView;
    NSAttributedString *attributedString;
    NSString *lorem;
    
    NSTextAlignment alignment;
    UIColor *color;
}
@end

@implementation TestBedViewController
- (void) setupToolbar
{
    UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)];
    RESIZABLE(tb);
    
    NSMutableArray *items = [NSMutableArray array];
    
    UIBarButtonItem *bbi;
    
    bbi = BARBUTTON(@"L", @selector(setAlignment:));
    bbi.tag = NSTextAlignmentLeft;
    [items addObject:bbi];
    
    bbi = BARBUTTON(@"C", @selector(setAlignment:));
    bbi.tag = NSTextAlignmentCenter;
    [items addObject:bbi];
    
    bbi = BARBUTTON(@"R", @selector(setAlignment:));
    bbi.tag = NSTextAlignmentRight;
    [items addObject:bbi];
    
    bbi = BARBUTTON(@"J", @selector(setAlignment:));
    bbi.tag = NSTextAlignmentJustified;
    [items addObject:bbi];
    
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
    
    bbi = BARBUTTON(@"X", @selector(setColor:));
    bbi.tag = 0;
    [items addObject:bbi];
    
    bbi = BARBUTTON(@"R", @selector(setColor:));
    bbi.tag = 1;
    [items addObject:bbi];
    
    bbi = BARBUTTON(@"G", @selector(setColor:));
    bbi.tag = 2;
    [items addObject:bbi];
    
    bbi = BARBUTTON(@"B", @selector(setColor:));
    bbi.tag = 3;
    [items addObject:bbi];
    
    tb.items = items;
    self.navigationItem.titleView = tb;
}

- (void) setupText
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = alignment;
    paragraphStyle.paragraphSpacing = 12.0f;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Futura" size:14.0f];
    attributes[NSForegroundColorAttributeName] = color;
    attributedString = [[NSAttributedString alloc] initWithString:lorem attributes: attributes];
    
    textView.attributedText = attributedString;
}

- (void) setAlignment: (UIBarButtonItem *) bbi
{
    alignment = bbi.tag;
    [self setupText];
}

- (void) setColor: (UIBarButtonItem *) bbi
{
    switch (bbi.tag)
    {
        case 0:
            color = [UIColor blackColor]; break;
        case 1:
            color = [UIColor redColor]; break;
        case 2:
            color = [UIColor greenColor]; break;
        case 3:
            color = [UIColor blueColor]; break;
        default: break;
    }
    [self setupText];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];

    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.editable = NO;
    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    
    lorem = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis eleifend risus id arcu volutpat porta. Cras vel dolor nec lectus iaculis luctus. Sed mollis, ante at bibendum pulvinar, purus dui pellentesque ipsum, quis pulvinar diam nisl in massa. Curabitur varius malesuada suscipit.\nPhasellus dictum, mi a rhoncus convallis, sapien nulla venenatis nisl, id consectetur tellus dui et est. Nullam tempor dapibus diam. Pellentesque urna enim, viverra et fringilla nec, lobortis non libero. Morbi sit amet erat sit amet lacus tempus venenatis vitae nec nulla.";
    
    alignment = NSTextAlignmentLeft;
    color = [UIColor blackColor];

    [self setupText];
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