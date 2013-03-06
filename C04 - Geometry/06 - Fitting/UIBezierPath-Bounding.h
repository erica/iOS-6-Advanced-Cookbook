/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import "UIBezierPath-Points.h"

@interface UIBezierPath (Bounding)
@property (nonatomic, readonly) UIBezierPath *convexHull;
@property (nonatomic, readonly) NSArray *sortedPoints;
@end

