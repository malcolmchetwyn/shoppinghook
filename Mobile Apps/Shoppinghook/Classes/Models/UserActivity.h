//
//  UserActivity.h
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 25/03/2014.

//

#import <Parse/Parse.h>

@interface UserActivity : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *fromUserId;
@property (nonatomic, strong) NSString *toUserId;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *newUserFacebookId;
@property (nonatomic, strong) NSString *newUserPhoneNo;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic)         BOOL processed;

@end
