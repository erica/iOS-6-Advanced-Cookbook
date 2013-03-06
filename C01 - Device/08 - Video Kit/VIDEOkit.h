/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface VIDEOkit : NSObject 
{
	UIImageView *baseView;	
}
@property (nonatomic, weak)   UIViewController *delegate;
@property (nonatomic, strong) UIWindow *outputWindow;
@property (nonatomic, strong) CADisplayLink *displayLink;

+ (void) startupWithDelegate: (id) aDelegate;
@end
