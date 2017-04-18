//
//  ABPushManager.h
//  Shoppinghook
//
//  Created on 11/05/2014.
//  
//

#import <Foundation/Foundation.h>

@interface ABPushManager : NSObject {
    
}

@property (nonatomic) NSUInteger activityRequestCount;
@property (nonatomic) NSUInteger friendRequestCount;

- (void)incrementActivityRequestCount;
- (void)resetActivityRequestCount;

- (void)incrementFriendRequestCount;
- (void)resetFriendRequestCount;

+ (ABPushManager*)sharedManager;

@end
