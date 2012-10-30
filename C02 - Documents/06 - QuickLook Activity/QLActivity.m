/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "QLActivity.h"
#import <QuickLook/QuickLook.h>

@interface QuickItem : NSObject <QLPreviewItem>
@property (nonatomic, strong) NSString *path;
@property (readonly) NSString *previewItemTitle;
@property (readonly) NSURL *previewItemURL;
@end

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

@implementation QLActivity
{
    NSArray *items;
    NSArray *qlitems;
    QLPreviewController *controller;
}
@end

@interface QLActivity (QLSource) <QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@end

@implementation QLActivity (QLSource)

- (NSString *)activityType
{
    return @"CustomQuickLookActivity";
}

- (NSString *) activityTitle
{
    return @"QuickLook";
}

- (UIImage *) activityImage
{
    return [UIImage imageNamed:@"QL.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (NSObject *item in activityItems)
        if ([item isKindOfClass:[NSURL class]])
        {
            NSURL *url = (NSURL *)item;
            if (url.isFileURL) return YES;
        }
    return NO;
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return qlitems.count;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index;
{
    return qlitems[index];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    items = activityItems;

    controller = [[QLPreviewController alloc] init];
    controller.dataSource = self;
    controller.delegate = self;
    
    NSMutableArray *finalArray = [NSMutableArray array];

    for (NSObject *item in items)
    {
        if ([item isKindOfClass:[NSURL class]])
        {
            NSURL *url = (NSURL *)item;
            if (url.isFileURL)
            {
                QuickItem *item = [[QuickItem alloc] init];
                item.path = url.path;
                [finalArray addObject:item];
            }
        }
    }
    
    qlitems = finalArray;
}

- (void) previewControllerDidDismiss:(QLPreviewController *)controller
{
    [self activityDidFinish:YES];
}

- (UIViewController *) activityViewController
{
    return controller;
}
@end
