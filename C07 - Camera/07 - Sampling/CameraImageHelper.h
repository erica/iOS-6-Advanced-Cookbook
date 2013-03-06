/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>

enum {
	kCameraNone = -1,
    kCameraBack,
	kCameraFront,
} availableCameras;

typedef enum {
    kAspect = 0, // AVLayerVideoGravityResizeAspect
    kResize,     // AVLayerVideoGravityResize
    kFill        // AVLayerVideoGravityResizeAspectFill
} previewAspect;

@interface CameraImageHelper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong)    AVCaptureSession *session;
@property (nonatomic, strong)    CIImage *ciImage;
@property (nonatomic, readonly)  UIImage *currentImage;
@property (nonatomic, readonly)  BOOL isUsingFrontCamera;

+ (int) numberOfCameras;
+ (BOOL) backCameraAvailable;
+ (BOOL) frontCameraAvailable;
+ (AVCaptureDevice *)backCamera;
+ (AVCaptureDevice *)frontCamera;

+ (instancetype) helperWithCamera: (uint) whichCamera;

- (void) startRunningSession;
- (void) stopRunningSession;
- (void) switchCameras;

- (void) embedPreviewInView: (UIView *) aView;
- (AVCaptureVideoPreviewLayer *) previewInView: (UIView *) view;
- (void) layoutPreviewInView: (UIView *) aView;
@end
