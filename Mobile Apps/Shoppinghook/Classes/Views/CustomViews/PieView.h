//
//  PieView.h
//  Pie
//
//  Created on 17/04/2014.
//  Copyright (c) 2014 Coeus Solutions GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PieView : UIView {
    
    UIView *smallCircle;
    UIImageView *hand;
}

@property (nonatomic) CGFloat currentRating;

- (void)setRating:(CGFloat)percentage;

@end
