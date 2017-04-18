//
//  ABInviteManager.h
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 17/04/2014.

//

#import <Foundation/Foundation.h>

@interface ABFriendRequestManager : NSObject

@property (nonatomic, strong) NSMutableArray *requests;

+(ABFriendRequestManager *)sharedManager;

@end
