//
//  ABActivityCache.h
//  Shoppinghook
//
//  Created by on 06/05/2014.
//

#import <Foundation/Foundation.h>
#import "Activity.h"


#define ACTIVITY_RESULTS @"activity_%@_results"
#define ACTIVITIES_REFRESHED @"ACTIVITIES_REFRESHED"

@interface ABActivityCache : NSObject {
    
    NSMutableArray *activities;
    NSMutableDictionary *activityDictionary;
    
}

- (NSArray*)getActivityRecordsWithActivityId:(NSString*)_activityId;

- (void)addMyActivity:(NSArray*)_activities;
- (void)deleteActivity:(Activity*)_activity;

- (void)newActivityWithActivityId:(NSString*)_activityId;

- (void)getActivitiesWithSuccess:(SuccessBlock)_success
                         failure:(ErrorBlock)_fail;

- (void)refreshActivitiesWithSuccess:(SuccessBlock)_success
                         failure:(ErrorBlock)_fail;

- (void)clear;


+ (ABActivityCache *)sharedCache;

@end
