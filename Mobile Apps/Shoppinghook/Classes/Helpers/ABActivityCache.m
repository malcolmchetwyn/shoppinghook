//
//  ABActivityCache.m
//  Shoppinghook
//
//  Created on 06/05/2014.
//

#import "ABActivityCache.h"

@implementation ABActivityCache

- (void)downloadImagesOfActivity:(Activity*)_activity {
    
    [[ABImageCache sharedCache] getPictureWithId:_activity.pic1 success:^(NSArray *result){} failure:^(NSError *error){}];
    
    if (_activity.pic2) {
        [[ABImageCache sharedCache] getPictureWithId:_activity.pic2 success:^(NSArray *result){} failure:^(NSError *error){}];
    }
    
    if (_activity.pic3) {
        [[ABImageCache sharedCache] getPictureWithId:_activity.pic3 success:^(NSArray *result){} failure:^(NSError *error){}];
    }
    
    if (_activity.pic4) {
        [[ABImageCache sharedCache] getPictureWithId:_activity.pic4 success:^(NSArray *result){} failure:^(NSError *error){}];
    }
    
    
    
}

- (NSArray*)getActivityRecordsWithActivityId:(NSString*)_activityId {
    
    NSArray *arr = activityDictionary[_activityId];
    return arr;
}

- (void)addMyActivity:(NSArray*)results {
    
    for (Activity *obj in results)
    {
        NSString *fromId = obj.activityId;
        NSMutableArray *arr = activityDictionary[fromId];
        if (!arr) {
            arr = [NSMutableArray array];
            activityDictionary[fromId] = arr;
        }
        [arr addObject:obj];
        [self downloadImagesOfActivity:obj];
    }
    
    [activities addObject:[results firstObject]];
    
    [self sortActivities];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVITIES_REFRESHED
                                                        object:nil];
    
}

- (void)deleteActivity:(Activity*)_activity {
    
    NSArray *toDelete = [self getActivityRecordsWithActivityId:_activity.activityId];
    
    [PFObject deleteAllInBackground:toDelete block:^(BOOL succeeded, NSError *error) {
        [activityDictionary removeObjectForKey:_activity.activityId];
        [activities removeObject:_activity];
        [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVITIES_REFRESHED
                                                            object:nil];
    }];
    
}

- (void)newActivityWithActivityId:(NSString*)_activityId {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:ACTIVITY_ID equalTo:_activityId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (Activity *obj in objects)
        {
            NSString *fromId = obj.activityId;
            NSMutableArray *arr = activityDictionary[fromId];
            if (!arr) {
                arr = [NSMutableArray array];
                activityDictionary[fromId] = arr;
            }
            [arr addObject:obj];
            [self downloadImagesOfActivity:obj];
        }
        
        [activities addObject:[objects firstObject]];
        
        [self sortActivities];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVITIES_REFRESHED
                                                            object:nil];
        
        
    }];
    
    
}

- (void)getActivitiesWithSuccess:(SuccessBlock)_success
                         failure:(ErrorBlock)_fail {
    
    if (!activities) {
        [self refreshActivitiesWithSuccess:_success failure:_fail];
    }
    else {
        _success(activities);
    }
    
}

- (void)sortActivities
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    [activities sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (void)refreshActivitiesWithSuccess:(SuccessBlock)_success
                             failure:(ErrorBlock)_fail {
    
    
    if (![[ABReachabilityManager sharedManager] isInternetAvailable]) {
        NSError *err = [NSError errorWithDomain:@"Shoppinghook" code:100 userInfo:@{}];
        _fail(err);
        return;
    }
    
    
    PFUser *user = [PFUser currentUser];
    
    PFQuery *fromQuery = [PFQuery queryWithClassName:@"Activity"];
    [fromQuery whereKey:FROM_USER_ID equalTo:user[CHANNEL]];
    //[fromQuery whereKey:STATUS equalTo:REQUEST];
    
    PFQuery *toQuery = [PFQuery queryWithClassName:@"Activity"];
    [toQuery whereKey:TO_USER_ID equalTo:user[CHANNEL]];
    //[toQuery whereKey:STATUS equalTo:REQUEST];
    
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[fromQuery,toQuery]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        if (!error)
        {
            if (results.count>0)
            {
                activities = [NSMutableArray new];
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                
                for (Activity *obj in results)
                {
                    NSString *fromId = obj.activityId;
                    NSMutableArray *arr = dictionary[fromId];
                    if (!arr) {
                        arr = [NSMutableArray array];
                        dictionary[fromId] = arr;
                    }
                    [arr addObject:obj];
                    
                    [self downloadImagesOfActivity:obj];
                    
                    [[ABActivityResultManager sharedManager] refreshActivityResultsForActivityId:obj.activityId success:^(NSDictionary *result) {}];
                }
                
                NSArray *keys = [dictionary allKeys];
                
                for (NSString *key in keys)
                {
                    NSMutableArray *array = dictionary[key];
                    [activities addObject:[array firstObject]];
                }
                
                activityDictionary = dictionary;
                
                [self sortActivities];
                
                _success(activities);
                
            }
            else
            {
                _success(@[]);
            }
        }
        else
        {
            _fail(error);
        }
        
    }];

}

- (void)clear {
    activities = nil;
    activityDictionary = nil;
}

#pragma mark - Initialization

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        activityDictionary = [NSMutableDictionary new];
        
    }
    
    return self;
}

#pragma mark - Shared Instance

+ (ABActivityCache *)sharedCache {
    static ABActivityCache *sharedCache = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache=[[ABActivityCache alloc] init];
    });
    
    return sharedCache;
}

@end
