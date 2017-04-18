//
//  ABActivityResultManager.h
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 11/05/2014.

//

#import <Foundation/Foundation.h>

typedef void (^ResultBlock)(NSDictionary* result);

@interface ABActivityResultManager : NSObject

- (void)getActivityResultsForActivityId:(NSString*)_activityId
                     success:(ResultBlock)_result;
- (void)refreshActivityResultsForActivityId:(NSString*)_activityId
                                    success:(ResultBlock)_result;

+ (ABActivityResultManager*)sharedManager;

@end
