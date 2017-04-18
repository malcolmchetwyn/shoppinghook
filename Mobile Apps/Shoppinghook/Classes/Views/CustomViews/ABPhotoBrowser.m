//
//  ABPhotoBrowser.m
//  Shoppinghook
//
//  Created on 30/03/2014.
//  
//

#import "ABPhotoBrowser.h"
#import "ABImageScrollView.h"
#import "UIImage+Resize.h"

#define MAIN_ITEM_WIDTH          CGRectGetWidth([[UIScreen mainScreen] bounds])
#define MAIN_ITEM_HEIGHT         CGRectGetHeight([[UIScreen mainScreen] bounds])

@implementation ABPhotoBrowser

#pragma mark - Initialize

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor blackColor];
}

#pragma mark - UIView Drawing

- (void)reDraw {
    
    [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *v = (UIView*)obj;
        [v removeFromSuperview];
    }];
    
    
    CGFloat xAxis  = 0.0;
    CGFloat yAxis  = 0.0;
    CGFloat width  = MAIN_ITEM_WIDTH;
    CGFloat height = MAIN_ITEM_HEIGHT;
    
    for (int i=0; i<items.count; i++) {
        
        // Add Full Image
        
        id image = items[i];
        
        ABImageScrollView *imageView = [ABImageScrollView loadFromNib];
        imageView.frame = CGRectMake(xAxis, yAxis, width, height);
        [imageView setImage:image];
        [imageView setTag:i];
        [scrollView addSubview:imageView];
        
        xAxis+=width;
    }
    
    scrollView.contentSize = CGSizeMake(items.count*width, height);
    
    [self selectItem];
    
}

- (void)reloadData {
    [self reDraw];
}

- (void)addItem:(UIImage *)_image {
    
    if (!items) {
        items = [NSMutableArray new];
    }
    
    [items addObject:_image];
    
    //self.selectedIndex = items.count-1;
    drawingIndex = items.count-1;
    
    [self reloadData];
}

- (void)addPictureWithId:(NSString *)_pictureId {
    
    if (!items) {
        items = [NSMutableArray new];
    }
    
    [items addObject:_pictureId];
    
    self.selectedIndex = items.count-1;
    
    [self reloadData];
    
}

- (void)removeItemAtIndex:(NSUInteger)_index {
    
    [items removeObjectAtIndex:_index];
    
    if (_index==0) {
        //self.selectedIndex=0;
        drawingIndex = 0;
    }
    else {
        //self.selectedIndex = _index-1;
        drawingIndex = _index-1;
    }
    
    [self reloadData];
    
}

- (NSUInteger)getItemCount {
    return items.count;
}

- (NSArray*)getItems {
    return items;
}

#pragma mark - Selection

- (void)selectItem {
    
    [scrollView scrollRectToVisible:CGRectMake(drawingIndex*MAIN_ITEM_WIDTH, 0.0, MAIN_ITEM_WIDTH, MAIN_ITEM_HEIGHT) animated:YES];
}

- (void)showItemAtIndex:(NSUInteger)_index {
    //self.selectedIndex = _index;
    drawingIndex = _index;
    [self selectItem];
}

- (void)clear {
    [items removeAllObjects];
    self.selectedIndex = 0;
    [self reDraw];
}

#pragma mark - UIScrollViewDelegate

- (void)setCurrentPage
{
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    
    NSUInteger lastIndex = self.selectedIndex;
    
    self.selectedIndex = page;
    
    for (UIView *v in scrollView.subviews) {
        if ([v isKindOfClass:[ABImageScrollView class]]) {
            if (v.tag!=self.selectedIndex) {
                ABImageScrollView *imageVIew = (ABImageScrollView*)v;
                [imageVIew setToMinimumZoom];
            }
        }
    }
    
    if (lastIndex==self.selectedIndex) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didScrolledToPage:)]) {
        [self.delegate didScrolledToPage:self.selectedIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    if (aScrollView==scrollView) {
        [self setCurrentPage];
        drawingIndex = self.selectedIndex;
        if ([self.delegate respondsToSelector:@selector(pageChanged:)]) {
            [self.delegate pageChanged:self.selectedIndex];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if (aScrollView==scrollView) {
        [self setCurrentPage];
    }
}

@end
