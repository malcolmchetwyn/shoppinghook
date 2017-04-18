//
//  ABUserManager.m
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 26/03/2014.

//

#import "ABUserManager.h"
#import "Group.h"


@implementation ABUserManager

- (void)addFriend:(PFUser*)_user {
    
    if (!self.parseFriends) {
        self.parseFriends = [NSMutableArray new];
    }
    
    [self.parseFriends addObject:_user];
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSArray *friendIds = [self.parseFriends valueForKey:CHANNEL];
    currentUser[FACEBOOK_FRIENDS]=friendIds;
    [currentUser saveInBackground];
    
    [self postNotifications:FRIENDS_REFRESHED];
}

- (void)removeFriend:(PFUser*)_user {
    
    if (self.parseFriends) {
        
        PFUser *currentUser = [PFUser currentUser];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",CHANNEL,_user[CHANNEL]];
        NSArray *users = [self.parseFriends filteredArrayUsingPredicate:predicate];
        
        if (users.count>0) {
            [self.parseFriends removeObject:[users firstObject]];
            NSArray *friendIds = [self.parseFriends valueForKey:CHANNEL];
            currentUser[FACEBOOK_FRIENDS]=friendIds;
            [currentUser saveInBackground];
            
            [self postNotifications:FRIENDS_REFRESHED];
        }
        
    }
}

- (void)fbFriendsWithSuccess:(SuccessBlock)_success
                     failure:(ErrorBlock)_failure {
    
    if (!fbFriends || fbFriends.count==0) {
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                
                NSArray *friendObjects = result[DATA];
                
                if (friendObjects.count>0) {
                    
                    NSMutableArray *allFBFriends = [NSMutableArray array];
                    
                    for (NSDictionary *friendObject in friendObjects) {
                        
                        NSString *facebookId = friendObject[UNIQUE_ID];
                        NSString *firstName  = friendObject[FIRST_NAME_A];
                        NSString *lastName   = friendObject[LAST_NAME_A];
                        
                        NSMutableDictionary *fbFriendDict = [@{FACEBOOK_ID:facebookId,FIRST_NAME:firstName} mutableCopy];
                        if (lastName) {
                            fbFriendDict[LAST_NAME] = lastName;
                        }
                        [allFBFriends addObject:fbFriendDict];
                    }
                    
                    fbFriends = [NSArray arrayWithArray:allFBFriends];
                    _success(fbFriends);
                    
                }
                else {
                    _failure(error);
                }
            }
            else {
                _failure(error);
            }
        }];
    }
    else {
        _success(fbFriends);
    }
    
}

- (void)clear {
    fbFriends = nil;
    self.parseFriends = nil;
}

#pragma mark - Get User Friends

- (void)refreshFriendsWithSuccess:(SuccessBlock)_success failure:(ErrorBlock)_failure
{
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserActivity"];
    
    [query whereKey:FROM_USER_ID equalTo:currentUser[CHANNEL]];
    [query whereKey:STATUS equalTo:FRIEND];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count>0) {
                
                NSArray *friendIds = [objects valueForKey:TO_USER_ID];
                currentUser[FACEBOOK_FRIENDS]=friendIds;
                [currentUser saveInBackground];
                
                [self getUsersWithIds:friendIds success:^(NSArray *friends) {
                    
                    self.parseFriends = [[NSMutableArray alloc] initWithArray:friends];
                    _success(self.parseFriends);
                    
                } failure:^(NSError *error) {
                    _failure(error);
                }];
            }
            else{
                currentUser[FACEBOOK_FRIENDS] = @[];
                _success(@[]);
            }
            
            [self refreshSentFriendRequestsWithSuccess:^(NSArray *objs) {} failure:^(NSError *err) {}];
        }
        else {
            _failure(error);
        }
    }];
}

- (void)getUserFriendsWithSuccess:(SuccessBlock)_success
                          failure:(ErrorBlock)_failure {
    
    if (!self.parseFriends) {
        
        [self refreshFriendsWithSuccess:_success failure:_failure];
    }
    else {
        _success(self.parseFriends);
    }
}

#pragma mark - Create Gropup

- (void)addGroupWithName:(NSString*)_name
                 friends:(NSArray*)_friends
                 success:(SuccessBlock)_success
                 failure:(ErrorBlock)_failure {
    
    NSMutableArray *friendIds = [NSMutableArray array];
    
    for (PFUser *user in _friends) {
        [friendIds addObject:user[CHANNEL]];
    }
    
    Group *newGroup = [Group new];
    newGroup.name = _name;
    [newGroup.users addObjectsFromArray:friendIds];
    if (!self.parseGroups) {
        self.parseGroups = [NSMutableArray new];
    }
    [self.parseGroups addObject:newGroup];
    
    [self postNotifications:GROUPS_REFRESHED];
    
    
    NSMutableArray *toAdd = [NSMutableArray array];
    
    for (NSString *userId in friendIds) {
        UserActivity *newActivity = [UserActivity objectWithClassName:@"UserActivity"];
        newActivity.fromUserId = [PFUser currentUser][CHANNEL];
        newActivity.toUserId   = userId;
        newActivity.status     = GROUP;
        newActivity.groupName  = _name;
        newActivity.processed  = @(YES);
        
        [toAdd addObject:newActivity];
    }
    
    [PFObject saveAllInBackground:toAdd block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            _success(@[]);
        }
        else{
            _failure(error);
        }
    }];
    
}

#pragma mark - Get Groups

- (NSMutableArray*)groupsWithEntries:(NSArray*)_objects {
    
    NSMutableArray *groups = [NSMutableArray array];
    
    NSString *lastGroupName;
    
    for (UserActivity *activity in _objects) {
        
        if (lastGroupName==nil || ![lastGroupName isEqualToString:activity.groupName]) {
            Group *newGroup = [Group new];
            newGroup.name = activity.groupName;
            [newGroup.users addObject:activity.toUserId];
            
            [groups addObject:newGroup];
            
        }
        else {
            Group *group = [groups lastObject];
            [group.users addObject:activity.toUserId];
        }
        
        lastGroupName = activity.groupName;
    }
    
    return groups;
}

- (void)getGroupsWithSuccess:(SuccessBlock)_success
                     failure:(ErrorBlock)_failure {
    
    if (!self.parseGroups) {
        [self refreshGroupsWithSuccess:_success failure:_failure];
    }
    else {
        _success(self.parseGroups);
    }
}

- (void)refreshGroupsWithSuccess:(SuccessBlock)_success
                         failure:(ErrorBlock)_failure
{
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserActivity"];
    
    [query whereKey:FROM_USER_ID equalTo:currentUser[CHANNEL]];
    [query whereKey:STATUS equalTo:GROUP];
    [query orderByAscending:GROUP_NAME];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count>0) {
                
                NSArray *groups = [self groupsWithEntries:objects];
                self.parseGroups = [[NSMutableArray alloc] initWithArray:groups];
                _success(self.parseGroups);
                
            }
            else{
                _success(@[]);
            }
        }
        else {
            _failure(error);
        }
        
    }];
    
}


#pragma mark - Friend Requests

- (void)requestToPeople:(NSArray*)users
                success:(SuccessBlock)_success
                failure:(ErrorBlock)_failure
{
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSMutableArray *toAdd = [NSMutableArray array];
    
    for (PFUser *user in users) {
        
        UserActivity *friendRequest = [UserActivity object];
        friendRequest.fromUserId = currentUser.objectId;
        friendRequest.toUserId = user.objectId;
        friendRequest.status = FRIEND_REQUEST;
        friendRequest.processed = NO;
        
        [toAdd addObject:friendRequest];
    }
    
    [PFObject saveAllInBackground:toAdd block:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            _success(@[]);
            [self refreshSentFriendRequestsWithSuccess:^(NSArray *objects) {} failure:^(NSError *error) {}];
        }
        else {
            _failure(error);
        }
    }];
    
}

- (void)addFriendRequest:(UserActivity*)_request {
    
    if (!self.friendRequests) {
        self.friendRequests = [NSMutableArray new];
    }
    
    [self.friendRequests addObject:_request];
    
    [self postNotifications:FRIENDS_REQUESTS_REFRESHED];
    
}

- (void)removeFriendRequest:(UserActivity*)_request {
    
    if (self.friendRequests) {
        [self.friendRequests removeObject:_request];
    }
}

- (void)getFriendRequestsWithSuccess:(SuccessBlock)_success
                             failure:(ErrorBlock)_failure
{
    
    if (self.friendRequests) {
        _success(self.friendRequests);
    }
    else {
        [self refreshFriendRequestsWithSuccess:_success
                                       failure:_failure];
    }
}

- (void)refreshFriendRequestsWithSuccess:(SuccessBlock)_success
                                 failure:(ErrorBlock)_failure {
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserActivity"];
    
    [query whereKey:TO_USER_ID equalTo:currentUser[CHANNEL]];
    [query whereKey:STATUS equalTo:FRIEND_REQUEST];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count>0) {
                
                self.friendRequests = [[NSMutableArray alloc] initWithArray:objects];
                _success(self.friendRequests);
            }
            else{
                self.friendRequests = [[NSMutableArray alloc] initWithArray:@[]];
                _success(self.friendRequests);
            }
        }
        else {
            _failure(error);
        }
    }];
}

- (NSArray*)userIdsOfFriendRequests {
    NSArray *ids = @[];
    
    if (self.friendRequests.count>0) {
        ids = [self.friendRequests valueForKey:FROM_USER_ID];
    }
    return ids;
}

- (void)acceptRequests:(NSArray *)acceptedRequests
               success:(SuccessBlock)_success
               failure:(ErrorBlock)_failure
{
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSMutableArray *toAdd = [NSMutableArray array];
    
    for (UserActivity *activity in acceptedRequests) {
        
        UserActivity *myRecord = [UserActivity object];
        myRecord.fromUserId = currentUser.objectId;
        myRecord.toUserId = activity.fromUserId;
        myRecord.status = FRIEND;
        myRecord.processed = NO;

        UserActivity *hisRecord = [UserActivity object];
        hisRecord.fromUserId = activity.fromUserId;
        hisRecord.toUserId = currentUser.objectId;
        hisRecord.status = FRIEND;
        hisRecord.processed = NO;
        
        [toAdd addObject:myRecord];
        [toAdd addObject:hisRecord];
        
    }
    
    if (![[ABReachabilityManager sharedManager] isInternetAvailable]) {
        
        for (UserActivity *add in toAdd) {
            [add saveEventually];
        }
        
        for (UserActivity *activity in acceptedRequests) {
            [activity deleteEventually];
        }
        _success(@[]);
        return;
    }
    
    [PFObject saveAllInBackground:toAdd block:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            _success(@[]);
        }
        else {
            _failure(error);
        }
    }];
    
    [PFObject deleteAllInBackground:acceptedRequests block:^(BOOL succeeded, NSError *error) {
        [self.friendRequests removeObjectsInArray:acceptedRequests];
        [self postNotifications:FRIENDS_REQUESTS_REFRESHED];
    }];
}

#pragma mark - Get Sent Requests

// Send Friend Requests

- (void)getSentFriendRequestsWithSuccess:(SuccessBlock)_success
                                 failure:(ErrorBlock)_failure {
    
    if (self.sentFriendRequests) {
        _success(self.sentFriendRequests);
    }
    else {
        [self refreshSentFriendRequestsWithSuccess:_success
                                           failure:_failure];
    }
    
}

- (void)refreshSentFriendRequestsWithSuccess:(SuccessBlock)_success
                                     failure:(ErrorBlock)_failure {
 
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserActivity"];
    
    [query whereKey:FROM_USER_ID equalTo:currentUser[CHANNEL]];
    [query whereKey:STATUS equalTo:FRIEND_REQUEST];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count>0) {
                
                self.sentFriendRequests = [[NSMutableArray alloc] initWithArray:objects];
                _success(self.sentFriendRequests);
            }
            else{
                self.sentFriendRequests = [[NSMutableArray alloc] initWithArray:@[]];
                _success(self.sentFriendRequests);
            }
        }
        else {
            _failure(error);
        }
    }];
}

- (NSArray*)userIdsOfSentFriendRequests {
    NSArray *ids = @[];
    
    if (self.sentFriendRequests.count>0) {
        ids = [self.sentFriendRequests valueForKey:TO_USER_ID];
    }
    return ids;
}

#pragma mark - Get Users

- (void)getUsersWithIds:(NSArray*)ids
                success:(SuccessBlock)_success
                failure:(ErrorBlock)_failure {
    
    PFQuery *query = [PFUser query];
    [query whereKey:CHANNEL containedIn:ids];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count>0) {
            _success(objects);
        }else{
            _success(@[]);
        }
        
        if (error) {
            _failure(error);
        }
    }];
}

#pragma mark - Facebook Session 

- (void)checkFacebookSessionWithSuccess:(SuccessBlock)_success
                                failure:(ErrorBlock)_failure
{
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser[FACEBOOK_ID]) {
        
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
         {
             if (!error)
             {
                 _success(@[]);
             }
             else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"])
             {
                 _failure(error);
             }
             else
             {
                 _success(@[]);
                 NSLog(@"Some other error: %@", error);
             }
         }];
    }

    
}

#pragma mark - Logout

- (void)logout
{
    [PFQuery clearAllCachedResults];
    [self clear];
    [[ABImageCache sharedCache] clear];
    [[ABActivityCache sharedCache] clear];
    
    
    
    [[ABKlaus appDelegate] unRegisterForPushNotifications];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:@"user"];
    [[PFInstallation currentInstallation] saveInBackground];
    
    [PFUser logOut];
}

#pragma mark - Notifications

- (void)postNotifications:(NSString*)_notificationName {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:_notificationName
                                                        object:nil];
}

#pragma mark - Class methods

+(ABUserManager *)sharedManager
{
    static ABUserManager* sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance=[[ABUserManager alloc] init];
    });
    return sharedInstance;
}

@end
