//
//  ABSplashViewController.m
//  Shoppinghook
//
//  Created on 24/04/2014.
//  
//

#import "ABSplashViewController.h"
#import "ABDataCaptureViewController.h"
#import "ABFeedViewController.h"

@interface ABSplashViewController () {
    
    ABDataCaptureViewController *dataCaptureController;
    ABFeedViewController        *feedController;
}

@end

@implementation ABSplashViewController

#pragma mark - Requests

- (void)synchronizeBackgroundData {

    PFUser *currentUser = [PFUser currentUser];
    
    if ([PFUser currentUser] && [[ABReachabilityManager sharedManager] isInternetAvailable]) {
        
        if (currentUser[FACEBOOK_ID]) {
            [[ABUserManager sharedManager] fbFriendsWithSuccess:^(NSArray *friends) {}
                                                        failure:^(NSError *error) {}];
        }
        
        [[ABUserManager sharedManager] refreshFriendsWithSuccess:^(NSArray *objects) {
            
            [[ABUserManager sharedManager] postNotifications:FRIENDS_REFRESHED];
        } failure:^(NSError *error) {}];
        
        [[ABUserManager sharedManager] refreshGroupsWithSuccess:^(NSArray *objects) {
            [[ABUserManager sharedManager] postNotifications:GROUPS_REFRESHED];
        } failure:^(NSError *error) {}];
        
    }
    
}

- (void) getFriendRequests {
    
    if ([PFUser currentUser] && [[ABReachabilityManager sharedManager] isInternetAvailable]) {
        [[ABUserManager sharedManager] refreshFriendRequestsWithSuccess:^(NSArray *objects) {
            [[ABUserManager sharedManager] postNotifications:FRIENDS_REQUESTS_REFRESHED];
            
            [[ABPushManager sharedManager] setFriendRequestCount:objects.count];
            
            [self getFeed];
            
        } failure:^(NSError *error) {}];
    }
    else {
        [self checkForFeedRequests];
    }
    
    [[ABUserManager sharedManager] refreshSentFriendRequestsWithSuccess:^(NSArray *objs) {
        [[ABUserManager sharedManager] postNotifications:FRIENDS_REQUESTS_REFRESHED];
    } failure:^(NSError *err) {}];
    
}

- (void) getFeed {
    
    if ([PFUser currentUser] && [[ABReachabilityManager sharedManager] isInternetAvailable]) {
        
        [[ABActivityCache sharedCache] refreshActivitiesWithSuccess:^(NSArray *objects) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVITIES_REFRESHED
                                                                object:nil];
            
            NSArray *feeds = [NSArray arrayWithArray:objects];
            
            NSDate *now = [NSDate date];
            NSDateComponents *minuteComponent = [[NSDateComponents alloc] init];
            minuteComponent.minute = -10;
    
            NSDate *expiryDate = [[NSCalendar currentCalendar] dateByAddingComponents:minuteComponent toDate:now options:0];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"createdAt>=%@ AND fromUserId!=%@ AND vote==nil",expiryDate,[PFUser currentUser][CHANNEL]];
            
            NSArray *newFeeds = [feeds filteredArrayUsingPredicate:predicate];
            
            if (newFeeds.count>0) {
                self.hasFeedRequests = YES;
            }
            
            [self checkForFeedRequests];
            
        } failure:^(NSError *error) {
            [self checkForFeedRequests];
        }];
    }
}

#pragma mark - VC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataCaptureController = [ABDataCaptureViewController loadFromNib];
    [dataCaptureController viewDidLoad];
    feedController        = [ABFeedViewController loadFromNib];
    
    [self synchronizeBackgroundData];
    [self getFriendRequests];
}

- (void)checkForFeedRequests
{
    NSArray *viewControllers = nil;
    
    if (!self.hasFeedRequests)
    {
        viewControllers = @[dataCaptureController];
    }
    else
    {
        viewControllers = @[dataCaptureController,feedController];
    }
    
    UINavigationController *rootNavCtr = (UINavigationController*)[[[ABKlaus appDelegate] window] rootViewController];
    
    [UIView animateWithDuration:0.25 animations:^{
        rootNavCtr.viewControllers = viewControllers;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //[self checkForFeedRequests];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
