/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import "CameraImageHelper.h"
#import "UIImage-CoreImage.h"
#import "Orientation.h"

#pragma mark Camera Image Helper

@implementation CameraImageHelper

#pragma mark Available Cameras
+ (int) numberOfCameras
{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}

+ (BOOL) backCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionBack) return YES;
    return NO;
}

+ (BOOL) frontCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionFront) return YES;
    return NO;
}

+ (AVCaptureDevice *)backCamera
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionBack) return device;
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

+ (AVCaptureDevice *)frontCamera
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionFront) return device;
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

#pragma mark Orientation: UIImage
- (UIImageOrientation) currentImageOrientation
{
    return currentImageOrientation(_isUsingFrontCamera, NO);
}

#pragma mark Image
- (UIImage *) currentImage
{
    UIImageOrientation orientation = currentImageOrientation(_isUsingFrontCamera, NO);
    return [UIImage imageWithCIImage:self.ciImage orientation:orientation];
    // return [UIImage imageWithCIImage:self.ciImage];
}

#pragma mark Preview Handling
- (void) embedPreviewInView: (UIView *) aView
{
    if (!_session) return;
    
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession: _session];
    preview.frame = aView.bounds;
    preview.videoGravity = AVLayerVideoGravityResizeAspect; // hmmm.
    [aView.layer addSublayer: preview];
}

- (UIView *) previewWithFrame: (CGRect) aFrame
{
    if (!_session) return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:aFrame];
    [self embedPreviewInView:view];
    
    return view;
}

- (AVCaptureVideoPreviewLayer *) previewInView: (UIView *) view
{
    for (CALayer *layer in view.layer.sublayers)
        if ([layer isKindOfClass:[AVCaptureVideoPreviewLayer class]])
            return (AVCaptureVideoPreviewLayer *)layer;
    
    return nil;
}

- (void) layoutPreviewInView: (UIView *) aView
{
    AVCaptureVideoPreviewLayer *layer = [self previewInView:aView];
    if (!layer) return;

    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CATransform3D transform = CATransform3DIdentity;
    if (orientation == UIDeviceOrientationPortrait) ;
    else if (orientation == UIDeviceOrientationLandscapeLeft)
        transform = CATransform3DMakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);
    else if (orientation == UIDeviceOrientationLandscapeRight)
        transform = CATransform3DMakeRotation(M_PI_2, 0.0f, 0.0f, 1.0f);
    else if (orientation == UIDeviceOrientationPortraitUpsideDown)
        transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    
    layer.transform = transform;
    layer.frame = aView.bounds;
}

#pragma mark Capture
- (void) switchCameras
{
    if (![CameraImageHelper numberOfCameras] > 1) return;
    
    _isUsingFrontCamera = !_isUsingFrontCamera;
    AVCaptureDevice *newDevice = _isUsingFrontCamera ? [CameraImageHelper frontCamera] : [CameraImageHelper backCamera];
    
    [_session beginConfiguration];
    
    // Remove existing inputs
    for (AVCaptureInput *input in [_session inputs])
        [_session removeInput:input];
    
    // Change the input
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];
    [_session addInput:captureInput];
    
    [_session commitConfiguration];
}

// Autorelease pool added thanks to suggestion by Josh Snyder -- May not be
// needed any more under ARC but retained in code for now
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool 
    {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        self.ciImage = [[CIImage alloc] initWithCVPixelBuffer:imageBuffer options:(__bridge_transfer NSDictionary *)attachments];
    }
}

#pragma mark Setup
- (void) startRunningSession
{
    if (_session.running) return;
    [_session startRunning];
}

- (void) stopRunningSession
{
    [_session stopRunning];
}

- (void) establishCamera: (uint) whichCamera
{
    NSError *error;
    
    // Is a camera available
    if (![CameraImageHelper numberOfCameras]) return;

    // Choose camera
    _isUsingFrontCamera = NO;
    if ((whichCamera == kCameraFront) && [CameraImageHelper frontCameraAvailable])
    _isUsingFrontCamera = YES;

    // Retrieve the selected camera
    AVCaptureDevice *device = _isUsingFrontCamera ? [CameraImageHelper frontCamera] : [CameraImageHelper backCamera];
    
    // Create the capture input
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!captureInput)
    {    
        NSLog(@"Error establishing device input: %@", error); 
        return;
    }
    
    // Create capture output
    // Update thanks to Jake Marsh who points out not to use the main queue
    char *queueName = "com.sadun.tasks.grabFrames";
    dispatch_queue_t queue = dispatch_queue_create(queueName, NULL);  
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES; 
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    // Establish settings
    NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [captureOutput setVideoSettings:settings];
    
    // Create a session
    self.session = [[AVCaptureSession alloc] init];
    [_session addInput:captureInput];
    [_session addOutput:captureOutput];
}

#pragma mark Creation
- (instancetype) init
{
    if (!(self = [super init])) return self;
    [self establishCamera: kCameraBack];
    return self;
}    

- (instancetype) initWithCamera: (uint) whichCamera
{
    if (!(self = [super init])) return self;    
    [self establishCamera: whichCamera];
    return self;
}

+ (instancetype) helperWithCamera: (uint) whichCamera
{
    CameraImageHelper *helper = [[CameraImageHelper alloc] initWithCamera:(uint) whichCamera];
    return helper;
}
@end
