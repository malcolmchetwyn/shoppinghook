//
//  ABActivityService.m
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 31/03/2014.
//

#import "ABActivityManager.h"
#import <Parse/Parse.h>
#import "Activity.h"
#import "Picture.h"

@implementation ABActivityManager

- (void)postActivityWithUserIds:(NSArray*)userIds
                         images:(NSArray*)_images

{
    
    NSMutableArray *toAdd = [NSMutableArray array];
    
    for (UIImage *image in _images) {
        
        Picture *picture = [Picture objectWithClassName:@"Picture"];
        picture.user = [PFUser currentUser][CHANNEL];
        NSData *imageData = UIImageJPEGRepresentation(image,0.5);
        picture.image = [PFFile fileWithName:@"Image.png" data:imageData];
        
        [toAdd addObject:picture];
    }
    
    [PFObject saveAllInBackground:toAdd block:^(BOOL succeeded, NSError *error) {
        
        for (Picture *p in toAdd) {
            [[ABImageCache sharedCache] savePicture:p];
        }
        
        NSLog(@"result returned");
        if (!error) {
            
            NSMutableArray *activities = [NSMutableArray array];
            
            NSString *fromUserId = [PFUser currentUser][CHANNEL];
            NSDate   *timestamp  = [NSDate date];
            NSString *activityId = [NSString stringWithFormat:@"%0.0f",[NSDate timeIntervalSinceReferenceDate]];
            
            NSString *pic1,*pic2,*pic3,*pic4 = nil;
            
            
            Picture *pic = nil;
            
            if (toAdd.count>=1) {
                pic = toAdd[0];
                pic1 = pic.objectId;
                
            }
            if (toAdd.count>=2) {
                pic = toAdd[1];
                pic2 = pic.objectId;
            }
            if (toAdd.count>=3) {
                pic = toAdd[2];
                pic3 = pic.objectId;
            }
            if (toAdd.count>=4) {
                pic = toAdd[3];
                pic4 = pic.objectId;
            }
            
            
            for (int i=0; i<userIds.count; i++) {
                
                NSString *toUserId = userIds[i];

                Activity *activity = [Activity objectWithClassName:@"Activity"];
                activity.activityId = activityId;
                activity.fromUserId = fromUserId;
                activity.toUserId   = toUserId;
                
                activity.pic1 = pic1;
                activity.pic2 = pic2 ? pic2:nil;
                activity.pic3 = pic3 ? pic3:nil;
                activity.pic4 = pic4 ? pic4:nil;
                
                activity.vote = nil;
                activity.timestamp = timestamp;
                activity.status = @"Request";
                activity.counter = @600;
                
                
                [activities addObject:activity];
                
            }
            
            [PFObject saveAllInBackground:activities block:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    [[ABActivityCache sharedCache] addMyActivity:activities];
                    
                }
                else {
                    
                }
            }];
            
        }
        else {
            
        }
    }];
    
    
}

#pragma mark - Class methods

+(ABActivityManager *)sharedManager
{
    static ABActivityManager* sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance=[[ABActivityManager alloc] init];
    });
    return sharedInstance;
}


@end
