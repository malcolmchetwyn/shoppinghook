//
//  ABBaseViewController.h
//  Shoppinghook
//
//  Created on 21/03/2014.
//  
//

#import <UIKit/UIKit.h>

@interface ABBaseViewController : UIViewController

@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (BOOL)isConnected;

- (void)setupLocalization;
- (void)setupUI;

- (void)showActivity;
- (void)hideActivity;

@end
