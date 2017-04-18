//
//  UIView+PopAnimation.m
//  Clover
//
//  Created by on 23/07/2013.
//  Copyright (c) 2013 Coeus Solutions GmbH. All rights reserved.
//

#import "UIView+PopAnimation.h"

@implementation UIView (PopAnimation)

- (void) show{
    
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.hidden = NO;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        
    }];
}

- (void) hide{
    self.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        [self endEditing:YES];
        self.hidden = YES;
        [self removeFromSuperview];
    }];
}

- (void)showWithCompletionBlock:(void (^)(void))completion{
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.hidden = NO;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        completion();
    }];
}


- (void)hideWithCompletionBlock:(void (^)(void))completion{
    
    self.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        [self endEditing:YES];
        self.hidden = YES;
        [self removeFromSuperview];
        
        completion();
    }];
}


@end
