

#import <AVFoundation/AVFoundation.h>

@protocol CaptureSessionManagerDelegate <NSObject>

@optional

- (void)imageCaptured:(UIImage*)_image
                 data:(NSData*)_imageData;

- (void)videoCapturedAtURL:(NSURL*)_url;

@end

//AVCaptureFileOutputRecordingDelegate

@interface CaptureSessionManager : NSObject {
    
    AVCaptureDevice *currentDevice;

}
@property (assign) id<CaptureSessionManagerDelegate> delegate;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) UIImage *stillImage;

- (void)addVideoPreviewLayer;
- (void)addStillImageOutput;

- (void)captureStillImage;
- (void)addVideoInputFrontCamera:(BOOL)front;
- (void)switchCamera;

- (BOOL)isFlashAvailable;
- (AVCaptureFlashMode)currentFlashMode;
- (void)setFlashMode:(AVCaptureFlashMode)_flashMode;

@end
