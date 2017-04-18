//
//  ABActivityCell.h
//  Shoppinghook
//
//  Created on 20/04/2014.
//  
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PieView.h"

@interface ABActivityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *viewOwner;
@property (weak, nonatomic) IBOutlet PFImageView *imgViewWinner;
@property (weak, nonatomic) IBOutlet PieView *viewRating;
@property (weak, nonatomic) IBOutlet PFImageView *imgViewSingleWinner;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@end
