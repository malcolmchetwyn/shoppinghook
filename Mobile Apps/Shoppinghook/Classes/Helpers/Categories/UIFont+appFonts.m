//
//  UIFont+appFonts.m
//  Dwight
//
//  Created by on 13/03/2014.

//

#import "UIFont+appFonts.h"

@implementation UIFont (appFonts)
+ (UIFont*)avenirLightFontWithSize:(CGFloat)_size {
    return [UIFont fontWithName:@"Avenir-Light" size:_size];
}

+ (UIFont*)avenirRomanFontWithSize:(CGFloat)_size {
    return [UIFont fontWithName:@"Avenir-Roman" size:_size];
}
@end
