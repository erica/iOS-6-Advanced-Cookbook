/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface FlowPath : NSObject
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, readonly) UIBezierPath *bezierPath;

+ (id) path;
- (void) addPoint: (CGPoint) aPoint;
- (void) stroke;
@end
