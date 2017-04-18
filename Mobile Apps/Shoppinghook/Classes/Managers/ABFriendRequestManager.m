//
//  ABInviteManager.m
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 17/04/2014.

//

#import "ABFriendRequestManager.h"

@implementation ABFriendRequestManager

#pragma mark - Class methods

+ (ABFriendRequestManager *)sharedManager
{
    static ABFriendRequestManager* sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance=[[ABFriendRequestManager alloc] init];
    });
    return sharedInstance;
}

@end
