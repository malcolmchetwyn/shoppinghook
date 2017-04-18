//
//  ABPhotoBrowser.h
//  Shoppinghook
//
//  Created on 30/03/2014.
//  
//

#import <UIKit/UIKit.h>

@protocol ABPhotoBrowserDelegate <NSObject>

@optional
- (void)didScrolledToPage:(NSUInteger)page;
- (void)pageChanged:(NSUInteger)page;
@end

@interface ABPhotoBrowser : UIView <UIScrollViewDelegate>{
    NSMutableArray *items;
    __weak IBOutlet UIScrollView *scrollView;
    NSUInteger drawingIndex;
}

@property (nonatomic) NSUInteger selectedIndex;
@property (assign)    id<ABPhotoBrowserDelegate> delegate;

- (NSUInteger)getItemCount;
- (NSArray*)getItems;
- (void)addItem:(UIImage*)_image;
- (void)addPictureWithId:(NSString*)_pictureId;
- (void)removeItemAtIndex:(NSUInteger)_index;
- (void)showItemAtIndex:(NSUInteger)_index;
- (void)clear;

@end
