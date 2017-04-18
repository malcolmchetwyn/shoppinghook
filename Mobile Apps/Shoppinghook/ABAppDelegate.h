//
//  ABAppDelegate.h
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 21/03/2014.
//

#import <UIKit/UIKit.h>

@class ABSplashViewController;

@interface ABAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic)         BOOL activatedFromBackground;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) ABSplashViewController *splashController;


- (void)setRootController;
- (void)registerForPushNotifications;
- (void)unRegisterForPushNotifications;
@end
