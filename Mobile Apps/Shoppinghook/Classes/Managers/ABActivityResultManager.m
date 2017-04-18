//
//  ABActivityResultManager.m
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 11/05/2014.

//

#import "ABActivityResultManager.h"

@interface ABActivityResultManager() {
    NSCache *cache;
}

@end

@implementation ABActivityResultManager

#pragma mark - RESULTS

- (NSString*)keyForActivityId:(NSString*)activityId {
    return [NSString stringWithFormat:@"%@_%@",ACTIVITY_ID,activityId];
}


- (void)getActivityResultsForActivityId:(NSString *)_activityId
                     success:(ResultBlock)_result {
    
    NSDictionary *cachedResult = [cache objectForKey:[self keyForActivityId:_activityId]];
    
    if (cachedResult) {
        _result(cachedResult);
    }
    else {
        [self refreshActivityResultsForActivityId:_activityId
                                          success:_result];
    }
}

- (void)refreshActivityResultsForActivityId:(NSString*)_activityId
                                    success:(ResultBlock)_result {
    
    [PFCloud callFunctionInBackground:@"totalCastedVotes"
                       withParameters:@{ACTIVITY_ID:_activityId}
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        [cache setObject:result forKey:[self keyForActivityId:_activityId]];
                                        _result((NSDictionary*)result);
                                    }
                                    else {
                                        NSLog(@"ERROR %@",error);
                                    }
                                }];
}



#pragma mark - Init + shared Instance

- (id)init {
    self = [super init];
    
    if (self) {
        cache = [[NSCache alloc] init];
    }
    
    return self;
}

+ (ABActivityResultManager *)sharedManager {
    
    static ABActivityResultManager *sharedManager= nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager=[[ABActivityResultManager alloc] init];
    });
    
    return sharedManager;
}

@end
