//
//  ABFriendListViewController.h
//  Shoppinghook
//
//  Created on 27/03/2014.
//  
//

#import "ABBaseViewController.h"

@protocol ActivityDelegate <NSObject>

@optional
- (void)activityPosted;
- (void)activitySaved;

@end

@interface ABFriendListViewController : ABBaseViewController

@property (nonatomic) id<ActivityDelegate> delegate;
@property (nonatomic, strong) NSArray *images;

@end
