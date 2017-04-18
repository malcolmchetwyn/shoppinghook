//
//  Activity.h
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 31/03/2014.

//

#import <Parse/Parse.h>

@interface Activity : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *activityId;
@property (nonatomic, strong) NSString *toUserId;
@property (nonatomic, strong) NSString *fromUserId;
@property (nonatomic, strong) NSString *pic1;
@property (nonatomic, strong) NSString *pic2;
@property (nonatomic, strong) NSString *pic3;
@property (nonatomic, strong) NSString *pic4;
@property (nonatomic, strong) NSString *vote;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSNumber *counter;
@property (nonatomic, strong) NSDate   *timestamp;

@end
