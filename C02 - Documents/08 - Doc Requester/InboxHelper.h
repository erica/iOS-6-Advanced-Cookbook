//
//  InboxHelper.h
//  HelloWorld
//
//  Created by Erica Sadun on 8/28/12.
//  Copyright (c) 2012 Erica Sadun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOCUMENTS_PATH  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define INBOX_PATH      [DOCUMENTS_PATH stringByAppendingPathComponent:@"Inbox"]

@interface InboxHelper : NSObject
+ (void) checkAndProcessInbox;
@end
