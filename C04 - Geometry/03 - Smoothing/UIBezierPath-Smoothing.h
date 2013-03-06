/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

UIBezierPath *smoothedPath(UIBezierPath *path, NSInteger granularity);
@interface UIBezierPath (Smoothing)
- (UIBezierPath *) smoothedPath: (NSInteger) granularity;
@end
