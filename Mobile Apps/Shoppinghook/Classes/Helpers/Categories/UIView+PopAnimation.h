//
//  UIView+PopAnimation.h
//  Clover
//
//  Created by on 23/07/2013.
//  Copyright (c) 2013 Coeus Solutions GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PopAnimation)

- (void) show;
- (void) hide;

- (void) showWithCompletionBlock:(void (^)(void))completion;
- (void) hideWithCompletionBlock:(void (^)(void))completion;

@end
