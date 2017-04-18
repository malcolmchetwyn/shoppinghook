//
//  ABImageScrollView.h
//  Shoppinghook
//
//  Created on 30/03/2014.
//  
//

#import <UIKit/UIKit.h>

@interface ABImageScrollView : UIView <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet PFImageView *imageView;

- (void)setImage:(id)_image;
- (void)setToMinimumZoom;

@end
