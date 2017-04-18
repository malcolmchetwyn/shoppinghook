//
//  ABContactsViewController.h
//  Shoppinghook
//
//  Created on 25/03/2014.
//  
//

#import "ABBaseViewController.h"

@interface ABFriendFinderViewController : ABBaseViewController

@property (nonatomic) Platform platform;
@property (nonatomic) NavigationMode navigationMode;

- (void)getContacts;

- (void)onSkip:(id)sender;
- (void)onNext:(id)sender;

@end
