//
//  UIView+xibLoad.h
//  Shoppinghook
//
//  Created by on 23/03/2014.
//  
//

#import <UIKit/UIKit.h>

@interface UIView (xibLoad)
+ (instancetype)loadFromNib;
+ (instancetype)loadFromNibNamed:(NSString*)_nibName;
@end
