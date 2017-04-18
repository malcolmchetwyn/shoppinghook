//
//  ABAppDelegate.m
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 21/03/2014.
//

#import "ABAppDelegate.h"
#import "Crittercism.h"
#import "ABStartViewController.h"
#import "ABSplashViewController.h"
#import "ABDataCaptureViewController.h"
#import "ABFriendCollectionViewController.h"

#import "UserActivity.h"
#import "Picture.h"
#import "Activity.h"

// Shoppinghook FB ID: 237836716421944
// For temp Use: 316951468443779

@implementation ABAppDelegate

#pragma mark - Parse Models

- (void)registerParseModels
{
    [PFImageView class];
    [UserActivity registerSubclass];
    [Picture registerSubclass];
    [Activity registerSubclass];
}

#pragma mark - Methods

- (void)setRootController
{
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser)
    {
        if (currentUser[FACEBOOK_ID])
        {
            if ([PFFacebookUtils isLinkedWithUser:currentUser])
            {
                _splashController = [ABSplashViewController loadFromNib];
                self.navigationController = [[UINavigationController alloc] initWithRootViewController:_splashController];
            }
            else
            {
                ABStartViewController *loginController = [ABStartViewController loadFromNib];
                self.navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
            }
        }
        else
        {
            _splashController = [ABSplashViewController loadFromNib];
            self.navigationController = [[UINavigationController alloc] initWithRootViewController:_splashController];
        }
        
    }
    else
    {
        ABStartViewController *loginController = [ABStartViewController loadFromNib];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
    }
    
    self.window.rootViewController = self.navigationController;
}

#pragma mark - Notification Sub/Unsub

- (void)registerForPushNotifications
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                                          UIRemoteNotificationTypeAlert |
                                                                          UIRemoteNotificationTypeSound];
}
- (void)unRegisterForPushNotifications
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

#pragma mark - Appearnce

- (void)setUpAppearnce
{
    if ([ABKlaus isIOS7AndHigher])
    {
        self.window.tintColor = [UIColor flatCloudsColor];
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor flatMidnightBlueColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor flatOrangeColor],
                                                               NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0]}];
        
        [[UIToolbar appearance] setBarTintColor:[UIColor flatMidnightBlueColor]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    [[UITextField appearance] setTintColor:[UIColor blackColor]];
}

#pragma mark - FB Session Validity 

- (void)checkFBSession {
    
    if (![PFUser currentUser]) {
        return;
    }
    
    [[ABUserManager sharedManager] checkFacebookSessionWithSuccess:^(NSArray *result) {
        
    } failure:^(NSError *error) {
        [ABErrorManager showAlertWithMessage:@"Your Facebook session has expired. Please Login again."];
        [[ABUserManager sharedManager] logout];
        [self setRootController];
    }];
}

#pragma mark - Application

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    [Crittercism enableWithAppID:CRITTERCISM_KEY];
    
    [[ABReachabilityManager sharedManager] startMonitoring];
    
    [self registerParseModels];
    
    [Parse setApplicationId:PARSE_APPLICATION_ID
                  clientKey:PARSE_CUSTOMER_KEY];
    
    [PFFacebookUtils initializeFacebook];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [self resetBadge];
    
    [self setUpAppearnce];
    
    [self setRootController];
    
    [self handlePush:launchOptions];
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    [self checkFBSession];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if ([PFUser currentUser] && [[ABReachabilityManager sharedManager] isInternetAvailable]) {
        
        [[ABActivityCache sharedCache] refreshActivitiesWithSuccess:^(NSArray *objects) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVITIES_REFRESHED
                                                                object:nil];
        } failure:^(NSError *error) {}];
        
        [[ABUserManager sharedManager] refreshFriendsWithSuccess:^(NSArray *objects) {
            
            [[ABUserManager sharedManager] postNotifications:FRIENDS_REFRESHED];
        } failure:^(NSError *error) {}];
        
        [[ABUserManager sharedManager] refreshGroupsWithSuccess:^(NSArray *objects) {
            [[ABUserManager sharedManager] postNotifications:GROUPS_REFRESHED];
        } failure:^(NSError *error) {}];
        
        [[ABUserManager sharedManager] refreshFriendRequestsWithSuccess:^(NSArray *objects) {
            [[ABUserManager sharedManager] postNotifications:FRIENDS_REQUESTS_REFRESHED];
            [[ABPushManager sharedManager] setFriendRequestCount:objects.count];
        } failure:^(NSError *error) {}];
        
        [[ABUserManager sharedManager] refreshSentFriendRequestsWithSuccess:^(NSArray *objs) {
            [[ABUserManager sharedManager] postNotifications:FRIENDS_REQUESTS_REFRESHED];
        } failure:^(NSError *err) {}];
        
        UIViewController *topController = [[self.navigationController viewControllers] lastObject];
        
        if ([topController isKindOfClass:[ABFriendCollectionViewController class]]) {
            ABFriendCollectionViewController *friendVC = (ABFriendCollectionViewController*)topController;
            [friendVC reload];
        }
        
        [self resetBadge];
        
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Clear badge and update installation, required for auto-incrementing badges.
    
    [self resetBadge];
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

#pragma mark - Application Push Methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self resetBadge];
    
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	if (error.code != 3010)
    {
        // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}


- (void)resetBadge
{
    // Clear badge and update installation, required for auto-incrementing badges.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        if ([[ABReachabilityManager sharedManager] isInternetAvailable]) {
            [currentInstallation saveInBackground];
        }
        else {
            [currentInstallation saveEventually];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    [self resetBadge];
    
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    NSString *requestType = userInfo[PUSH_REQUEST];
    NSString *resourceId = userInfo[RESOURCE_ID];
    
    if ([requestType isEqualToString:NEW_ACTIVITY_REQUEST]) {
        [[ABActivityCache sharedCache] newActivityWithActivityId:resourceId];
        [[ABPushManager sharedManager] incrementActivityRequestCount];
        [PFPush handlePush:userInfo];

    }
    else if ([requestType isEqualToString:NEW_FRIEND_REQUEST]) {
        
        UserActivity *activity = [UserActivity objectWithoutDataWithObjectId:resourceId];
        
        [activity fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [[ABUserManager sharedManager] addFriendRequest:activity];
            [[ABPushManager sharedManager] incrementFriendRequestCount];
            //[PFPush handlePush:userInfo];
        }];
    }
    else if ([requestType isEqualToString:NEW_VOTE]) {
        [[ABActivityResultManager sharedManager] refreshActivityResultsForActivityId:resourceId
                                                                             success:^(NSDictionary *result) {}];
        [PFPush handlePush:userInfo];
    }
    else if ([requestType isEqualToString:NEW_FRIEND]) {
        
        [[ABUserManager sharedManager] getUsersWithIds:@[resourceId] success:^(NSArray *objects) {
            if (objects.count>0) {
                PFUser *user = objects[0];
                [[ABUserManager sharedManager] addFriend:user];
                [PFPush handlePush:userInfo];
            }
        } failure:^(NSError *error) {}];
        
        
    }
    
    [self resetBadge];
    
}

#pragma mark - Handle Background Push

- (void)handlePush:(NSDictionary *)launchOptions {
    
    [self resetBadge];
    
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotificationPayload)
    {
        if ([PFUser currentUser])
        {
            
            NSString *requestType = remoteNotificationPayload[PUSH_REQUEST];
            NSString *resourceId = remoteNotificationPayload[RESOURCE_ID];
            
            if ([requestType isEqualToString:NEW_ACTIVITY_REQUEST]) {
                
//                if (_splashController) {
//                    _splashController.hasFeedRequests = YES;
//                }
                [[ABPushManager sharedManager] incrementActivityRequestCount];
            }
            else if ([requestType isEqualToString:NEW_FRIEND_REQUEST]) {
                [[ABPushManager sharedManager] incrementFriendRequestCount];
            }
            else if ([requestType isEqualToString:NEW_VOTE]) {
                [[ABActivityResultManager sharedManager] refreshActivityResultsForActivityId:resourceId success:^(NSDictionary *result) { }];
            }
            else if ([requestType isEqualToString:NEW_FRIEND]) {
                
            }
        }
    }
}


@end
