/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface QuickItem : NSObject <QLPreviewItem>
@property (nonatomic, strong) NSString *path;
@property (readonly) NSString *previewItemTitle;
@property (readonly) NSURL *previewItemURL;
@end
