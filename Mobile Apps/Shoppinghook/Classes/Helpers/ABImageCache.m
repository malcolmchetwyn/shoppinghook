//
//  ABImageCache.m
//  Shoppinghook
//
//  Created by on 04/05/2014.
//  
//

#import "ABImageCache.h"

@interface ABImageCache() {
    NSCache *cache;
}

@end

@implementation ABImageCache

- (void)getImage:(PFFile *)_file {
    
    PFImageView *imageView = [[PFImageView alloc] init];
    [imageView setFile:_file];
    [imageView loadInBackground];
}

- (void)getPictureWithId:(NSString *)_pictureId
                 success:(SuccessBlock)_success
                 failure:(ErrorBlock)_fail
{
    
    Picture *pic = [self getPictureWithPictureId:_pictureId];
    if (pic) {
        _success(@[pic]);
    }
    else {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Picture"];
        [query whereKey:OBJECT_ID equalTo:_pictureId];
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                Picture *pic = (Picture*)object;
                [self savePicture:pic];
                _success(@[pic]);
            }
            else {
                _fail(error);
            }
        }];
    }
}

- (void)savePicture:(Picture*)_picture {
    pictures[_picture.objectId] = _picture;
    [self getImage:_picture.image];
}

- (Picture*)getPictureWithPictureId:(NSString*)_pictureId {
    Picture *pic = pictures[_pictureId];
    return pic;
}

- (void)clear {
    [pictures removeAllObjects];
}

#pragma mark - Initialization

- (id)init {
    
    self = [super init];
    
    if (self) {
        __internalImageView = [[PFImageView alloc] init];
        pictures = [@{} mutableCopy];
    }
    
    return self;
}

#pragma mark - Shared Instance

+ (ABImageCache *)sharedCache {
    static ABImageCache *sharedCache = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache=[[ABImageCache alloc] init];
    });
    
    return sharedCache;
}

@end
