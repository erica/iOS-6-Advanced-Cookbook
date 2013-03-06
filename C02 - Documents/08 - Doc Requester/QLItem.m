/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import "QLItem.h"

@implementation QuickItem
- (NSString *) previewItemTitle
{
    return [_path lastPathComponent];
}

- (NSURL *) previewItemURL
{
    return [NSURL fileURLWithPath:_path];
}
@end

