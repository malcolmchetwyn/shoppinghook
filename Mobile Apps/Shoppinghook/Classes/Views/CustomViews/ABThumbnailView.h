//
//  ABThumbnailView.h
//  Shoppinghook
//
//  Created on 04/04/2014.
//  
//

#import <UIKit/UIKit.h>

@protocol ThumbnailSelectionDelegate <NSObject>
@optional

- (void)thumbnailSelectedAtIndex:(NSUInteger)selectedIndex;

@end

@interface ABThumbnailView : UIView

@property (weak) id<ThumbnailSelectionDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic) NSInteger selectedIndex;

- (void)addImage:(UIImage*)_image;
- (void)addPictureWithId:(NSString*)_pictureId;
- (void)removeImageAtIndex:(NSUInteger)_index;
- (void)selectImageAtIndex:(NSUInteger)_index;
- (void)clear;

- (CGRect)rectForNextItem;

@end
