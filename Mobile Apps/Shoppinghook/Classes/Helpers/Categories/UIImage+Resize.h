//
//  UIImage+Resize.h
//  Shoppinghook
//
//  Created by on 30/03/2014.
//  
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)
-(UIImage*)resizedImageToSize:(CGSize)dstSize;
-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;
@end
