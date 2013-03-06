/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "TableInACan.h"

@implementation TableInACan
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_listItems) return _listItems.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"generic" forIndexPath:indexPath];
    
    id item = _listItems[indexPath.row];
    cell.textLabel.text = [item description];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_cannedDelegate) return;

    id item = _listItems[indexPath.row];
    
    if ([_cannedDelegate respondsToSelector:@selector(didSelectItem:atIndexPath:)])
        [_cannedDelegate didSelectItem:item atIndexPath:indexPath];
}

- (void) viewDidAppear: (BOOL) animated
{
	self.rowHeight = 72.0f;
}

- (id) initWithFrame: (CGRect) aFrame
{
    if (!(self = [super initWithFrame:aFrame]))
        return nil;
    
    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"generic"];
    
    return self;
}

// Cite: http://www.youtube.com/watch?v=anwy2MPT5RE

+ (id) tableWithList: (NSArray *) aList
{
    TableInACan *spam = [[TableInACan alloc] initWithFrame:CGRectZero];
    
    spam.listItems = aList;
    spam.delegate = spam;
    spam.dataSource = spam;

    return spam;
}
@end
