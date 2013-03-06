/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@protocol CannedDelegate <NSObject>
@optional
- (void) didSelectItem: (id) item atIndexPath: (NSIndexPath *) anIndexPath;
@end

@interface TableInACan : UITableView <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *listItems;
@property (nonatomic, weak) id <CannedDelegate> cannedDelegate;
+ (id) tableWithList: (NSArray *) aList;
@end
