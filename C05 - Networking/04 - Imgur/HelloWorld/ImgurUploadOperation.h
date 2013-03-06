/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@protocol ImgurUploadOperationDelegate <NSObject>
@optional
- (void) handleImgurOperationError: (NSString *) errorMessage;
- (void) finishedImgurOperationWithData: (NSData *) data;
@end

@interface ImgurUploadOperation : NSOperation
@property (nonatomic) UIImage *image;
@property (nonatomic, weak) id delegate;
+ (id) operationWithDelegate: (id <ImgurUploadOperationDelegate>) delegate andImage: (UIImage *) image;
@end
