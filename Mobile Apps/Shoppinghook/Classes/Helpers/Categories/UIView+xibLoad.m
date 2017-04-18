//
//  UIView+xibLoad.m
//  Shoppinghook
//
//  Created by on 23/03/2014.
//  
//

#import "UIView+xibLoad.h"

@implementation UIView (xibLoad)

+ (instancetype)loadFromNib {
    NSString *xibName = NSStringFromClass([self class]);
    return [UIView loadFromNibNamed:xibName];
}

+ (instancetype)loadFromNibNamed:(NSString *)_nibName {
    return [[NSBundle mainBundle] loadNibNamed:_nibName owner:nil options:nil][0];
}

@end
