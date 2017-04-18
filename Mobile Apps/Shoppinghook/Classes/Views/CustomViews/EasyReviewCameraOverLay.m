

#import "EasyReviewCameraOverLay.h"
#import "UIImage+Resize.h"
#import "UIView+Genie.h"

@implementation EasyReviewCameraOverLay

#pragma mark - Actions

- (void)showPhotoBrowser {
    
    currentMode = DataModeBrowse;
    photoBrowser.hidden = NO;
    cameraButton.hidden = NO;
    swapButton.hidden = YES;
}

- (void)hidePhotoBrowser {

    currentMode = DataModeCapture;
    photoBrowser.hidden = YES;
    cameraButton.hidden = YES;
    swapButton.hidden = NO;
}

- (void) showHideImageThumbnails
{
    [UIView animateWithDuration:0.1 animations:^{
        if (thumbnailView.images.count>0) {
            thumbnailView.hidden = NO;
            trashButton.hidden = NO;
            saveButton.hidden = NO;
        }
        else {
            thumbnailView.hidden = YES;
            trashButton.hidden = YES;
            saveButton.hidden = YES;
        }
    }];
}

- (void)captureImage:(id)sender {
    
    [helpLabel removeFromSuperview];
    
    if ([photoBrowser getItemCount]>=4) {
        [ABErrorManager showAlertWithMessage:@"You've already taken 4 pictures."];
        return;
    }
    captureButton.enabled = NO;
    [[self captureManager] captureStillImage];
}

- (void)goBackToCamera:(UIButton*)_button {
    [self hidePhotoBrowser];
}

- (void)toggleCamera:(UIButton*)_button {
    
    [self.captureManager switchCamera];
    [self hideShowFlashButton];
}

- (void)toggleFlash:(UIButton*)_button {
    
    if ([self.captureManager currentFlashMode]==AVCaptureFlashModeOn ||
        [self.captureManager currentFlashMode]==AVCaptureFlashModeAuto) {
        [self.captureManager setFlashMode:AVCaptureFlashModeOff];
        _button.alpha = 0.3;
    }
    else {
        [self.captureManager setFlashMode:AVCaptureFlashModeOn];
        _button.alpha = 1.0;
    }
}

- (void)saveData:(UIButton*)_button {
    
    if ([photoBrowser getItemCount]>0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagesCaptured:)]) {
            [self.delegate imagesCaptured:[photoBrowser getItems]];
        }
    }
}

- (void)deleteSelectedItem:(UIButton*)_button {
    
    if ([photoBrowser getItemCount]>0 && thumbnailView.selectedIndex!=-1) {
        
        [thumbnailView removeImageAtIndex:thumbnailView.selectedIndex];
        [photoBrowser removeItemAtIndex:photoBrowser.selectedIndex];
        
        
        if ([photoBrowser getItemCount]==0) {
            [self hidePhotoBrowser];
            [self showHideImageThumbnails];
        }
    }
    else {
        [ABErrorManager showAlertWithMessage:@"You've not taken or selected any images yet."];
        currentMode = DataModeCapture;
        trashButton.hidden = YES;
        photoBrowser.hidden = YES;
        
    }
    
}

- (void)goToFeed:(UIButton*)_button {
    
    if (self.parentVC && [self.parentVC respondsToSelector:@selector(goToFeed)]) {
        [self.parentVC performSelector:@selector(goToFeed)];
    }
    
}

#pragma mark - Customizations

-(void) addCaptureButton{
    
    captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    captureButton.frame = self.bounds;
    [captureButton setTitle:@" " forState:UIControlStateNormal];
    [captureButton setBackgroundColor:[UIColor clearColor]];
    [captureButton addTarget:self action:@selector(captureImage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:captureButton];
    
}

- (void)addPhotoBrowser {
    
    photoBrowser = [ABPhotoBrowser loadFromNib];
    photoBrowser.delegate = self;
    [self addSubview:photoBrowser];
    photoBrowser.hidden =YES;
}

- (void)addThumbView {
    
    thumbnailView = [ABThumbnailView loadFromNib];
    thumbnailView.delegate = self;
    
    CGRect rect = thumbnailView.bounds;
    rect.origin.y = self.frame.size.height - rect.size.height;
    thumbnailView.frame = rect;
    
    [self addSubview:thumbnailView];
    thumbnailView.hidden =YES;
    
}

- (void)addCameraButton {
    cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setFrame:CGRectMake(self.bounds.size.width - 44.0 ,20.0, 44.0, 44.0)];
    [cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(goBackToCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cameraButton];
    cameraButton.hidden = YES;
}

- (void)addSwapCameraButton
{
    swapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [swapButton setFrame:CGRectMake(self.bounds.size.width - 44.0 ,20.0, 44.0, 44.0)];
    [swapButton setImage:[UIImage imageNamed:@"cameraShuffle"] forState:UIControlStateNormal];
    [swapButton addTarget:self action:@selector(toggleCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:swapButton];
    
}

- (void)addFlashButton
{
    flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashButton setFrame:CGRectMake(0.0 ,20.0, 44.0, 44.0)];
    [flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    [flashButton addTarget:self action:@selector(toggleFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:flashButton];
    
}

- (void)addSaveButton {
    
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake(0.0 ,self.frame.size.height-168, 44.0, 44.0)];
    [saveButton setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveData:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:saveButton];
    
    saveButton.hidden = YES;
    
}

- (void)addTrashButton {
    
    trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [trashButton setFrame:CGRectMake(self.bounds.size.width-88 ,self.frame.size.height-168, 44.0, 44.0)];
    [trashButton setImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
    [trashButton addTarget:self action:@selector(deleteSelectedItem:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:trashButton];
    
    trashButton.hidden = YES;
}

- (void)addFeedButton {
    feedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [feedButton setFrame:CGRectMake(self.bounds.size.width-44 ,self.frame.size.height-168, 44.0, 44.0)];
    [feedButton setImage:[UIImage imageNamed:@"feed"] forState:UIControlStateNormal];
    [feedButton addTarget:self action:@selector(goToFeed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:feedButton];
}

- (void)addHelpLabel {
    helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    helpLabel.text = @"Tap anywhere for picture";
    helpLabel.textColor = [UIColor whiteColor];
    helpLabel.textAlignment  =NSTextAlignmentCenter;
    [self addSubview:helpLabel];
    helpLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)hideShowFlashButton
{
    if ([self.captureManager isFlashAvailable]) {
        flashButton.hidden = NO;
        
        if ([self.captureManager currentFlashMode]==AVCaptureFlashModeOff) {
            flashButton.alpha = 0.3;
        }
        else {
            flashButton.alpha = 1.0;
        }
    }
    else {
        flashButton.hidden = YES;
    }
}

- (void)clear {

    [photoBrowser clear];
    [thumbnailView clear];
    [self hidePhotoBrowser];
    [self showHideImageThumbnails];
}

#pragma mark - Init

-(void)setDefaults {
    [self setBackgroundColor:[UIColor blackColor]];
    self.layer.cornerRadius = 0;
    self.layer.masksToBounds = YES;
    currentMode = DataModeCapture;
}

- (void)startCamera
{
    [self setCaptureManager:[[CaptureSessionManager alloc] init]];
    [self.captureManager setDelegate:self];
    [[self captureManager] addVideoInputFrontCamera:NO];
    [[self captureManager] addStillImageOutput];
    [[self captureManager] addVideoPreviewLayer];
    
    CGRect layerRect = self.bounds;
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
    [[self layer] addSublayer:[[self captureManager] previewLayer]];
    
    [[[self captureManager] captureSession] startRunning];
}

- (void)setUpUI {
    
    [self addCaptureButton];
    
    [self addFlashButton];
    [self addSwapCameraButton];
    
    [self addPhotoBrowser];
    [self addThumbView];
    
    [self addCameraButton];

    [self addSaveButton];
    [self addTrashButton];
    [self addFeedButton];
    [self hideShowFlashButton];
    [self addHelpLabel];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setDefaults];
        [self startCamera];
        [self setUpUI];
    }
    return self;
}

#pragma mark - CaptureDelegate

- (void)imageCaptured:(UIImage*)_image data:(NSData*)_imageData {
    
    thumbnailView.hidden = NO;
    
    _image = [_image resizedImageToFitInSize:self.bounds.size scaleIfSmaller:YES];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeRedraw;
    imageView.image = _image;
    
    imageView.layer.borderColor = [UIColor clearColor].CGColor;
    imageView.layer.borderWidth = 2.0;
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 5.0;
    
    [self addSubview:imageView];
    
    CGRect endRect = [thumbnailView rectForNextItem];
    
    [imageView genieInTransitionWithDuration:0.75
                             destinationRect:endRect
                             destinationEdge:BCRectEdgeTop
                                  completion:^{
                                      
                                      [thumbnailView addImage:_image];
                                      [photoBrowser addItem:_image];
                                      [self showHideImageThumbnails];
                                      
                                      [imageView removeFromSuperview];
                                      
                                      captureButton.enabled = YES;
                                  }];
}

#pragma mark - ThumbnailSeletionDelegate

- (void)thumbnailSelectedAtIndex:(NSUInteger)selectedIndex {
    [self showPhotoBrowser];
    [photoBrowser showItemAtIndex:selectedIndex];
}

#pragma mark - PhotoBrowserDelegate
- (void)didScrolledToPage:(NSUInteger)page {
    
    NSLog(@"%d --- %d",page,thumbnailView.selectedIndex);
    
    thumbnailView.delegate = nil;
    
    if (thumbnailView.selectedIndex!=page) {
        [thumbnailView selectImageAtIndex:page];
    }
    
    NSLog(@"%d --- %d",page,thumbnailView.selectedIndex);
    
    thumbnailView.delegate = self;
    
}

- (void)pageChanged:(NSUInteger)page {
//    thumbnailView.delegate = nil;
//    [thumbnailView selectImageAtIndex:page];
//    thumbnailView.delegate = self;
}
@end
