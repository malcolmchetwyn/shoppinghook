//
//  PieView.m
//  Pie
//
//  Created on 17/04/2014.
//  Copyright (c) 2014 Coeus Solutions GmbH. All rights reserved.
//

#import "PieView.h"

@import QuartzCore;

#define   DEGREES_TO_RADIANS(degrees)  ((3.14 * degrees)/ 180)

@implementation PieView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _currentRating = 0.0;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _currentRating = 0.0;
}

- (void)setRating:(CGFloat)percentage
{
    
    _currentRating = percentage;
    
    CGFloat factor = 1.4;
    CGFloat startAngle = 160.0;
    
    CGFloat expectedAngle = startAngle - (factor*percentage);
    
    CGFloat uiAngle = -1 * (expectedAngle-90.0);
    
    [self setHandValue:uiAngle];
}


- (void)setHandValue:(CGFloat)angle {
    
    [UIView beginAnimations:@"rotate" context:nil];
    [UIView setAnimationDuration:0.5];
    hand.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(angle));
    [UIView commitAnimations];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    if (!hand) {
        hand = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2.0-2, 0, 4, self.bounds.size.height-2)];

        [hand setImage:[UIImage imageNamed:@"hand"]];
        [self addSubview:hand];
        
        [[hand layer] setAnchorPoint:CGPointMake(0.0,1.0)];
        CGPoint position = hand.layer.position;
        position.y+= hand.bounds.size.height/2;
        [[hand layer] setPosition:position];
        
        [self setRating:_currentRating];
    }
    
    if (!smallCircle) {
        
        CGFloat width = CGRectGetWidth(self.bounds)/5;
        
        smallCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0,width,width)];
        smallCircle.backgroundColor = [UIColor flatWetAsphaltColor];
        
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), self.bounds.size.height);
        smallCircle.center = center;
        
        [self addSubview:smallCircle];
        
        smallCircle.layer.cornerRadius = width/2;
        smallCircle.layer.masksToBounds = YES;
        
    }
    
    self.clipsToBounds = YES;
    
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGPoint center = CGPointMake(self.bounds.size.width/2.0,self.bounds.size.height);
    
    CGFloat radius = self.bounds.size.width/2.0 - 4.0;
    
    
    UIBezierPath *background = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:self.bounds.size.width/2.0-2.0
                                                          startAngle:0.0
                                                            endAngle:DEGREES_TO_RADIANS(180.0)
                                                           clockwise:NO];
    
    [background closePath];
    
    
    [[UIColor flatWetAsphaltColor] setFill];
    [background fill];
    
    
    UIBezierPath *arcPath1 = [UIBezierPath bezierPathWithArcCenter:center
                                                           radius:radius
                                                       startAngle:0.0
                                                         endAngle:DEGREES_TO_RADIANS(300.0)
                                                        clockwise:NO];
    [arcPath1 addLineToPoint:center];
    
    
    UIBezierPath *arcPath2 = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:radius
                                                        startAngle:DEGREES_TO_RADIANS(300.0)
                                                          endAngle:DEGREES_TO_RADIANS(240.0)
                                                         clockwise:NO];
    [arcPath2 addLineToPoint:center];
    
    UIBezierPath *arcPath3 = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:radius
                                                        startAngle:DEGREES_TO_RADIANS(240.0)
                                                          endAngle:DEGREES_TO_RADIANS(180.0)
                                                         clockwise:NO];
    [arcPath3 addLineToPoint:center];
    
    [[UIColor clearColor] setStroke];
    
    [[UIColor flatNephritisColor] setFill];
    [arcPath1 fill];
    [arcPath1 stroke];
    
    [[UIColor whiteColor] setFill];
    [arcPath2 fill];
    [arcPath2 stroke];
    
    [[UIColor flatPomegranateColor] setFill];
    [arcPath3 fill];
    [arcPath3 stroke];
}

@end
