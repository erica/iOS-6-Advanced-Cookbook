/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>
#import "ReflectingView.h"

@interface ReflectingViewController : UIViewController
+ (id) controller;
@property (nonatomic, strong) ReflectingView *backsplash;
@end
