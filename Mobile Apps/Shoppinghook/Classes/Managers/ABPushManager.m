//
//  ABPushManager.m
//  Shoppinghook
//
//  Created on 11/05/2014.
//  
//

#import "ABPushManager.h"

@implementation ABPushManager


- (void)incrementActivityRequestCount {
    ++self.activityRequestCount;
    [[NSNotificationCenter defaultCenter] postNotificationName:NEW_ACTIVITY_REQUEST_NOTIFICATION object:nil];
}

- (void)resetActivityRequestCount {
    self.activityRequestCount = 0;
}

- (void)incrementFriendRequestCount {
    ++self.friendRequestCount;
    [[NSNotificationCenter defaultCenter] postNotificationName:NEW_FRIEND_REQUEST_NOTIFICATION object:nil];
}

- (void)resetFriendRequestCount {
    self.friendRequestCount = 0;
}

- (void)setFriendRequestCount:(NSUInteger)friendRequestCount {
    _friendRequestCount = friendRequestCount;
}


#pragma mark - Init + shared Instance

- (id)init {
    self = [super init];
    
    if (self) {
        self.activityRequestCount = 0;
        self.friendRequestCount = 0;
    }
    
    return self;
}

+ (ABPushManager *)sharedManager {
    
    static ABPushManager *sharedManager= nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager=[[ABPushManager alloc] init];
    });
    
    return sharedManager;
}

@end
