//
//  ABActivityService.h
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 31/03/2014.
//

#import <Foundation/Foundation.h>

@interface ABActivityManager : NSObject

- (void)postActivityWithUserIds:(NSArray*)userIds
                         images:(NSArray*)_images;

+ (ABActivityManager*)sharedManager;

@end
