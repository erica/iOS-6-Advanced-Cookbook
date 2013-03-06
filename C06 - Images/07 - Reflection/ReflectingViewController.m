/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import "ReflectingViewController.h"
#define RESIZABLE(_VIEW_) [_VIEW_ setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth]

@implementation ReflectingViewController
- (void) loadView
{
    [super loadView];
    self.view.autoresizesSubviews = YES;
    RESIZABLE(self.view);

    _backsplash = [[ReflectingView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_backsplash];
    RESIZABLE(_backsplash);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect destFrame = self.view.bounds;
    destFrame = CGRectInset(destFrame, 0.0f, 50.0f);
    destFrame = CGRectOffset(destFrame, 0.0f, -50.0f);
    _backsplash.frame = destFrame;

    [_backsplash setupReflection];
}

+ (id) controller
{
    ReflectingViewController *controller = [[ReflectingViewController alloc] init];    
    return controller;
}
@end
