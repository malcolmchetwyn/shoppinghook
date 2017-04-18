//
//  ABKlaus.m
//  Dwight
//
//  Created by on 02/03/2014.

//

#import "ABKlaus.h"
#import "ABAppDelegate.h"

@implementation ABKlaus

#pragma mark -
#pragma mark - IPAD or IPHONE

+ (BOOL)isIPAD{
    BOOL iPAD = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        iPAD = YES;
    }
    return iPAD;
}

#pragma mark - OS Version

+ (BOOL) isIOS7AndHigher {
    
    BOOL iOS7 = NO;
    
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        iOS7 = YES;
    }
    return iOS7;
}

#pragma mark - AppDelegate Ref

+ (ABAppDelegate*) appDelegate {
    return (ABAppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - Valid Email check

+ (BOOL)isValidEmail:(NSString*)_email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:_email];
}

#pragma mark - Fix Image Orientation

+ (UIImage*)fixOrientation:(UIImage*)_image {
    
    // No-op if the orientation is already correct
    if (_image.imageOrientation == UIImageOrientationUp) return _image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (_image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, _image.size.width, _image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, _image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, _image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (_image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, _image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, _image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, _image.size.width, _image.size.height,
                                             CGImageGetBitsPerComponent(_image.CGImage), 0,
                                             CGImageGetColorSpace(_image.CGImage),
                                             CGImageGetBitmapInfo(_image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (_image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,_image.size.height,_image.size.width), _image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,_image.size.width,_image.size.height), _image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
