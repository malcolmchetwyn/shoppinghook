//
//  ABImageScrollView.m
//  Shoppinghook
//
//  Created on 30/03/2014.
//  
//

#import "ABImageScrollView.h"
#import "UIScrollView+BDDRScrollViewAdditions.h"
#import "Picture.h"

@implementation ABImageScrollView


- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.scrollView.bddr_centersContent = YES;
	self.scrollView.bddr_doubleTapZoomInEnabled = YES;
	self.scrollView.bddr_doubleTapZoomsToMinimumZoomScaleWhenAtMaximumZoomScale = YES;
	self.scrollView.bddr_twoFingerZoomOutEnabled = YES;
	self.scrollView.bddr_oneFingerZoomEnabled = NO;
	
	self.scrollView.backgroundColor = [UIColor blackColor];
	self.scrollView.delegate = self;
	self.scrollView.minimumZoomScale = 1.0f;
	self.scrollView.maximumZoomScale = 2.0f;
    
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    
}

#pragma mark - Set Image

- (void)setImage:(id)_image {
    
    if ([_image isKindOfClass:[UIImage class]]) {
        self.imageView.image = _image;
    }
    else {
        
        [[ABImageCache sharedCache] getPictureWithId:(NSString*)_image
                                             success:^(NSArray *result) {
                                                 
                                                    Picture *pic = [result firstObject];
                                                    self.imageView.file = pic.image;
                                                    [self.imageView loadInBackground];
                                                 
                                             }
                                             failure:^(NSError *error) {
                                                 
                                             }];
    }
}

- (void)setToMinimumZoom {
    
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	if (scrollView != self.scrollView) return nil;
	return self.imageView;
}

@end
