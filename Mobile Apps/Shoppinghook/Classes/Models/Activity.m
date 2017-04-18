//
//  Activity.m
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 31/03/2014.

//

#import "Activity.h"

@implementation Activity

@dynamic activityId,toUserId,fromUserId,pic1,pic2,pic3,pic4,vote,status,counter,timestamp;


+ (NSString *)parseClassName {
    return @"Activity";
}

@end
