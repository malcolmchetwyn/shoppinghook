//
//  ABActivityCell.m
//  Shoppinghook
//
//  Created on 20/04/2014.
//  
//

#import "ABActivityCell.h"

@implementation ABActivityCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imgViewWinner.file cancel];
    self.imgViewWinner.file = nil;
    self.imgViewWinner.image = nil;
    
    [self.imgViewSingleWinner.file cancel];
    self.imgViewSingleWinner.file = nil;
    self.imgViewSingleWinner.image = nil;
}

@end
