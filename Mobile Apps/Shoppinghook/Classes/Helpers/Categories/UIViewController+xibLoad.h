//
//  UIViewController+xibLoad.h
//  Dwight
//
//  Created by on 02/03/2014.

//

#import <UIKit/UIKit.h>

@interface UIViewController (xibLoad)

+ (instancetype)loadFromNib;
+ (instancetype)loadFromNibNamed:(NSString*)_nibName;

@end
