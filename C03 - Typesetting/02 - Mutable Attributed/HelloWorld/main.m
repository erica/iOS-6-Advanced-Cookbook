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
    NSMutableAttributedString *attributedString;
    NSString *lorem;
}
@end

@implementation TestBedViewController
- (void) setupToolbar
{
    UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)];
    RESIZABLE(tb);
    
    NSMutableArray *items = [NSMutableArray array];
    
    UIBarButtonItem *bbi;
   
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
    
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
    
    while (self.undoManager.isRedoing) ;
    while (self.undoManager.isUndoing) ;
    
	BOOL canUndo = [self.undoManager canUndo];
    UIBarButtonItem *undoItem = SYSBARBUTTON_TARGET(UIBarButtonSystemItemUndo, self.undoManager, @selector(undo));
    undoItem.enabled = canUndo;
    [items addObject:undoItem];
    
	BOOL canRedo = [self.undoManager canRedo];
    UIBarButtonItem *redoItem = SYSBARBUTTON_TARGET(UIBarButtonSystemItemRedo, self.undoManager, @selector(redo));
    redoItem.enabled = canRedo;
    [items addObject:redoItem];
    
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
    
    bbi = BARBUTTON(@"S", @selector(setFontSize:));
    bbi.tag = 18;
    [items addObject:bbi];
    
    bbi = BARBUTTON(@"M", @selector(setFontSize:));
    bbi.tag = 24;
    [items addObject:bbi];
    
    bbi = BARBUTTON(@"L", @selector(setFontSize:));
    bbi.tag = 36;
    [items addObject:bbi];

    tb.items = items;
    self.navigationItem.titleView = tb;
}

- (void) setToolbarEnabled: (BOOL) yorn
{
    UIToolbar *tb = (UIToolbar *) self.navigationItem.titleView;
    for (UIBarButtonItem *item in tb.items)
        item.enabled = yorn;
}

- (void)textViewDidChangeSelection:(UITextView *) aTextView
{
//    BOOL rangeAvailable = (textView.selectedRange.location != NSNotFound);
//    [self setToolbarEnabled:rangeAvailable];
}

- (void) initializeText
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 12.0f;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Futura" size:24.0f];
    attributedString = [[NSMutableAttributedString alloc] initWithString:lorem attributes: attributes];
    
    textView.attributedText = attributedString;
}

- (void) setAttrStringFrom: (NSAttributedString *) sourceAttributedString to: (NSAttributedString *) destAttributedString
{
    [[self.undoManager prepareWithInvocationTarget:self] setAttrStringFrom:[destAttributedString copy] to:[sourceAttributedString copy]];
    
    [self.undoManager beginUndoGrouping];
    [self.undoManager setActionName:@"Update"];
    textView.attributedText = destAttributedString;
    [self.undoManager endUndoGrouping];
    
    [self performSelector:@selector(setupToolbar) withObject:nil afterDelay:0.1f];
}

- (void) applyAttribute: (id) attributeValue withName: (NSString *) keyName
{
    NSRange range = textView.selectedRange;
    if (range.location == NSNotFound) return;
    
    // Replicating this approach through custom code
    // [attributedString addAttribute:keyName value:attributeValue range:range];
    
    // Keep track of attribute range effects
    CGFloat fullExtent = range.location + range.length;
    CGFloat currentLocation = range.location;
 
    // Iterate through effective ranges
    while (currentLocation < (fullExtent - 1))
    {
        NSRange effectiveRange;
        NSDictionary *currentAttributes = [attributedString attributesAtIndex:currentLocation effectiveRange:&effectiveRange];
        NSRange intersection = NSIntersectionRange(range, effectiveRange);

        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:currentAttributes];
        attributes[keyName] = attributeValue;
        [attributedString setAttributes:attributes range:intersection];
        
        currentLocation = effectiveRange.location + effectiveRange.length;
    }
    
    [self setAttrStringFrom:textView.attributedText to:attributedString];
}

- (void) setColor: (UIBarButtonItem *) bbi
{
    UIColor *color;
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
    
    [self applyAttribute:color withName:NSForegroundColorAttributeName];
}

- (void) setFontSize: (UIBarButtonItem *) bbi
{
    UIFont *newFont = [UIFont fontWithName:@"Futura" size:(CGFloat)bbi.tag];
    [self applyAttribute:newFont withName:NSFontAttributeName];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];    
    
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.editable = NO;
    textView.delegate = self;

    [self.view addSubview:textView];
    PREPCONSTRAINTS(textView);
    STRETCH_VIEW(self.view, textView);
    
    lorem = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis eleifend risus id arcu volutpat porta. Cras vel dolor nec lectus iaculis luctus. Sed mollis, ante at bibendum pulvinar, purus dui pellentesque ipsum, quis pulvinar diam nisl in massa. Curabitur varius malesuada suscipit.\nPhasellus dictum, mi a rhoncus convallis, sapien nulla venenatis nisl, id consectetur tellus dui et est. Nullam tempor dapibus diam. Pellentesque urna enim, viverra et fringilla nec, lobortis non libero. Morbi sit amet erat sit amet lacus tempus venenatis vitae nec nulla.";

    [self initializeText];
    [self setupToolbar];
    [self setToolbarEnabled:YES];
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