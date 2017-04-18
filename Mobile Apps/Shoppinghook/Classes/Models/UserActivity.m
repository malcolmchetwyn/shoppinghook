//
//  UserActivity.m
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 25/03/2014.

//

#import "UserActivity.h"

@implementation UserActivity

@dynamic fromUserId,toUserId,status,newUserFacebookId,newUserPhoneNo,groupName,processed;

+ (NSString *)parseClassName {
    return @"UserActivity";
}

@end
