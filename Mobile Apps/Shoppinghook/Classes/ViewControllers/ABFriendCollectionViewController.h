//
//  ABFViewController.h
//  SEGMENT
//
//  Created on 22/04/2014.
//  Copyright (c) 2014 Coeus Solutions GmbH. All rights reserved.
//

#import "ABBaseViewController.h"

@interface ABFriendCollectionViewController : ABBaseViewController

@property (strong, nonatomic) UIBarButtonItem *leftBarItem;
@property (strong, nonatomic) UIBarButtonItem *rightBarItem;

@property (nonatomic) BOOL showsFriendRequest;
@property (nonatomic) Platform platform;
@property (nonatomic) NavigationMode navigationMode;

- (void)reload;

- (BOOL)isViewControllerAtTop:(ABBaseViewController*)_viewController;

@end
