//
//  ABImageCache.h
//  Shoppinghook
//
//  Created by on 04/05/2014.
//  
//

#import <Foundation/Foundation.h>
#import "Picture.h"

@interface ABImageCache : NSObject {
    
    NSMutableDictionary *pictures;
    
    PFImageView *__internalImageView;
}

- (void)getImage:(PFFile*)_file;
- (void)savePicture:(Picture*)_picture;

- (void)getPictureWithId:(NSString*)_pictureId
                 success:(SuccessBlock)_success
                 failure:(ErrorBlock)_fail;

- (void)clear;

+ (ABImageCache*)sharedCache;

@end
