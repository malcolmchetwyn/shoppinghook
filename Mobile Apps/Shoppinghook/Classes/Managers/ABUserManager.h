//
//  ABUserManager.h
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 26/03/2014.

//

#import <Foundation/Foundation.h>
#import "UserActivity.h"


@interface ABUserManager : NSObject {
    
    NSArray *fbFriends;
}

@property (nonatomic, strong) NSMutableArray *parseFriends;
@property (nonatomic, strong) NSMutableArray *parseGroups;
@property (nonatomic, strong) NSMutableArray *friendRequests;
@property (nonatomic, strong) NSMutableArray *sentFriendRequests;

// Friends

- (void)addFriend:(PFUser*)_user;
- (void)removeFriend:(PFUser*)_user;
- (void)fbFriendsWithSuccess:(SuccessBlock)_success
                     failure:(ErrorBlock)_failure;

- (void)getUserFriendsWithSuccess:(SuccessBlock)_success
                          failure:(ErrorBlock)_failure;

- (void)refreshFriendsWithSuccess:(SuccessBlock)_success
                          failure:(ErrorBlock)_failure;

// Groups

- (void)addGroupWithName:(NSString*)_name
                 friends:(NSArray*)_friends
                 success:(SuccessBlock)_success
                 failure:(ErrorBlock)_failure;
- (void)getGroupsWithSuccess:(SuccessBlock)_success
                     failure:(ErrorBlock)_failure;
- (void)refreshGroupsWithSuccess:(SuccessBlock)_success
                         failure:(ErrorBlock)_failure;

// Friend Requests

- (void)requestToPeople:(NSArray*)users
                success:(SuccessBlock)_success
                failure:(ErrorBlock)_failure;

- (void)addFriendRequest:(UserActivity*)_request;
- (void)removeFriendRequest:(UserActivity*)_request;

- (void)getFriendRequestsWithSuccess:(SuccessBlock)_success
                             failure:(ErrorBlock)_failure;

- (void)refreshFriendRequestsWithSuccess:(SuccessBlock)_success
                                 failure:(ErrorBlock)_failure;

- (NSArray*)userIdsOfFriendRequests;

- (void)acceptRequests:(NSArray*)acceptedRequests
               success:(SuccessBlock)_success
               failure:(ErrorBlock)_failure;

// Send Friend Requests

- (void)getSentFriendRequestsWithSuccess:(SuccessBlock)_success
                             failure:(ErrorBlock)_failure;

- (void)refreshSentFriendRequestsWithSuccess:(SuccessBlock)_success
                                 failure:(ErrorBlock)_failure;

- (NSArray*)userIdsOfSentFriendRequests;


// Users

- (void)getUsersWithIds:(NSArray*)ids
                success:(SuccessBlock)_success
                failure:(ErrorBlock)_failure;

// Facebook Session

- (void)checkFacebookSessionWithSuccess:(SuccessBlock)_success
                                failure:(ErrorBlock)_failure;

// Logout and Cleansing

- (void)logout;
- (void)clear;

- (void)postNotifications:(NSString*)_notificationName;

+(ABUserManager *)sharedManager;

@end
