/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface NSAttributedString (Rendered)
@property (nonatomic, readonly) CGSize renderedSize;
@property (nonatomic, readonly) CGFloat renderedWidth;
@property (nonatomic, readonly) CGFloat renderedHeight;
@property (nonatomic, readonly) NSAttributedString *versionWithoutNewLines;
@end
