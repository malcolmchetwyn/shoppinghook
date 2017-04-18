
#import <UIKit/UIKit.h>
#import "ABPhotoBrowser.h"
#import "ABThumbnailView.h"
#import "CaptureSessionManager.h"

typedef enum {
    DataModeCapture=0,
    DataModeBrowse
}DataMode;

@protocol ImageCaptureDelegate <NSObject>
@optional
- (void)imagesCaptured:(NSArray*)_images;
@end

@interface EasyReviewCameraOverLay : UIView <CaptureSessionManagerDelegate,ThumbnailSelectionDelegate,ABPhotoBrowserDelegate>{
    
    ABThumbnailView *thumbnailView;
    ABPhotoBrowser  *photoBrowser;
    DataMode         currentMode;
    
    UILabel         *helpLabel;
    
    UIButton        *captureButton;
    UIButton        *flashButton;
    UIButton        *cameraButton;
    UIButton        *swapButton;
    UIButton        *saveButton;
    UIButton        *trashButton;
    UIButton        *feedButton;
}

@property (weak) id<ImageCaptureDelegate> delegate;

@property (strong, nonatomic) CaptureSessionManager *captureManager;
@property (nonatomic, assign) UIViewController *parentVC;
@property (nonatomic, strong) UIImage *stillImage;

- (void)clear;

-(id)initWithFrame:(CGRect)frame;

@end
