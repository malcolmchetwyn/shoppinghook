//
//  UIViewController+xibLoad.m
//  Dwight
//
//  Created by on 02/03/2014.

//

#import "UIViewController+xibLoad.h"

@implementation UIViewController (xibLoad)

+ (instancetype)loadFromNib {
    NSString *xibName = NSStringFromClass([self class]);
    return  [[self class] loadFromNibNamed:xibName];
}

+ (instancetype)loadFromNibNamed:(NSString*)_nibName {
    return [[self alloc] initWithNibName:_nibName bundle:nil];
}

@end
