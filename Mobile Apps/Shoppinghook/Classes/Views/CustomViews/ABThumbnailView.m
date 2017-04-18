//
//  ABThumbnailView.m
//  Shoppinghook
//
//  Created on 04/04/2014.
//  
//

#import "ABThumbnailView.h"
#import "UIImage+Resize.h"
#import "Picture.h"

#define THUMBNAIL_MIDDLE_PADDING 10.0
#define THUMBNAIL_TOP_PADDING    5.0
#define THUMBNAIL_HEIGHT         110.0
#define THUMBNAIL_WIDTH          70.0

@implementation ABThumbnailView

- (void)thumbnailTapped:(UIButton*)_button {
    [self selectImageWithTag:_button.tag];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.images = [NSMutableArray new];
    self.tag = 2333;
    self.selectedIndex = -1;
}

- (void)reDraw {
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *v = (UIView*)obj;
        [v removeFromSuperview];
    }];
    
    CGFloat thumnailXAxis = THUMBNAIL_MIDDLE_PADDING/2.0;
    
    for (int i=0; i<self.images.count; i++) {
        
        id image = self.images[i];
        
        
        UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake(thumnailXAxis, THUMBNAIL_TOP_PADDING, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];
        thumbView.layer.borderColor = [UIColor clearColor].CGColor;
        thumbView.layer.borderWidth = 2.0;
        thumbView.layer.masksToBounds = YES;
        thumbView.layer.cornerRadius = 5.0;
        [thumbView setTag:i];
        
        PFImageView *imageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        
        if ([image isKindOfClass:[UIImage class]]) {
            imageView.image = [image resizedImageToFitInSize:CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT) scaleIfSmaller:YES];
        }
        else {
            
            [[ABImageCache sharedCache] getPictureWithId:(NSString*)image
                                                 success:^(NSArray *result) {
                                                     
                                                     Picture *pic = [result firstObject];
                                                     imageView.file = pic.image;
                                                     [imageView loadInBackground];
                                                     
                                                 }
                                                 failure:^(NSError *error) {
                                                     
                                                 }];
            
        }
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];
        [button setTag:i];
        
        [button addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [thumbView addSubview:imageView];
        [thumbView addSubview:button];
        
        [self addSubview:thumbView];
        // Move xAxis to Next View
        thumnailXAxis += THUMBNAIL_WIDTH+THUMBNAIL_MIDDLE_PADDING;
        
    }
    
    [self showSelected];
}


- (void)addImage:(UIImage*)_image
{
    [self.images addObject:_image];
    self.selectedIndex = self.images.count-1;
    [self reDraw];
}


- (void)addPictureWithId:(NSString*)_pictureId {
    [self.images addObject:_pictureId];
    self.selectedIndex = self.images.count-1;
    [self reDraw];
}


- (void)removeImageAtIndex:(NSUInteger)_index
{
    [self.images removeObjectAtIndex:_index];
    
    if (_index==0) {
        self.selectedIndex=0;
    }
    else {
        self.selectedIndex = _index-1;
    }
    
    if (self.images.count==0) {
        self.selectedIndex = -1;
    }
    
    [self reDraw];
}

- (void)clear {
    self.selectedIndex = 0;
    [self.images removeAllObjects];
    [self reDraw];
}

- (void)showSelected
{
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *v = (UIView*)obj;
        v.hidden = YES;
        v.layer.borderColor = [UIColor clearColor].CGColor;
    }];
    
    if (self.selectedIndex==-1) {
        return;
    }
    
    UIView *v = [self viewWithTag:self.selectedIndex];
    v.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *v = (UIView*)obj;
        v.hidden = NO;
    }];
}

- (void)selectImageWithTag:(NSUInteger)_viewTag
{
    
    self.selectedIndex = _viewTag;
    
    [self showSelected];
    
    if ([self.delegate respondsToSelector:@selector(thumbnailSelectedAtIndex:)]) {
        [self.delegate thumbnailSelectedAtIndex:self.selectedIndex];
    }
}

- (void)selectImageAtIndex:(NSUInteger)_index
{
    [self selectImageWithTag:_index];
}

#pragma mark - Animation Helpers

- (CGRect)rectForNextItem {
    
    NSUInteger currentLastIndex = _images.count-1;
    NSUInteger nextLastIndex    = currentLastIndex+1;
    
    CGFloat initialThumnailXAxis = THUMBNAIL_MIDDLE_PADDING/2.0;
    
    initialThumnailXAxis = initialThumnailXAxis + ((THUMBNAIL_WIDTH+THUMBNAIL_MIDDLE_PADDING)*nextLastIndex);
    
    CGRect rectInSelf = CGRectMake(initialThumnailXAxis, THUMBNAIL_TOP_PADDING, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT);
    
    CGRect rectInSuperView = [self convertRect:rectInSelf toView:self.superview];
    
    return rectInSuperView;
}

@end
