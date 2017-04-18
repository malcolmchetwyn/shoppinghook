//
//  ABSettingsViewController.m
//  Shoppinghook
//
//  Created on 08/04/2014.
//  
//

#import "ABSettingsViewController.h"
#import "NotificationView.h"
#import "ABManageFriendViewController.h"
#import "ABFriendCollectionViewController.h"
#import "ABPolicyAndTermsViewController.h"
#import "ABWebViewController.h"
#import "ABCreateGroupViewController.h"

@interface ABSettingsViewController ()

- (IBAction)onFriendRequests:(id)sender;
- (IBAction)onGroup:(id)sender;
- (IBAction)onNotifications:(id)sender;
- (IBAction)onManageFriends:(id)sender;
- (IBAction)onPolicyandTerms:(id)sender;
- (IBAction)onLogout:(id)sender;

@end

@implementation ABSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onFriendRequests:(id)sender
{
    ABFriendCollectionViewController *friendVC = [ABFriendCollectionViewController loadFromNib];
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser[FACEBOOK_ID]) {
        friendVC.platform = PlatformFacebook;
    }
    else {
        friendVC.platform = PlatformPhoneBook;
    }
    friendVC.showsFriendRequest = YES;
    friendVC.navigationMode = NavigationModeGoBack;
    [self.navigationController pushViewController:friendVC animated:YES];
}

- (IBAction)onGroup:(id)sender
{
     [self.navigationController pushViewController:[ABCreateGroupViewController loadFromNib] animated:YES];
}

- (IBAction)onNotifications:(id)sender
{
    NotificationView *notificationView = [NotificationView notificationView];
    [notificationView showNotificationWithDelegate:nil];
}

- (IBAction)onManageFriends:(id)sender
{
    ABManageFriendViewController *friendVC = [ABManageFriendViewController loadFromNib];
    [self.navigationController pushViewController:friendVC animated:YES];
}

- (IBAction)onPolicyandTerms:(id)sender
{
    ABPolicyAndTermsViewController *policyVC = [ABPolicyAndTermsViewController loadFromNib];
    [self.navigationController pushViewController:policyVC animated:YES];
}

- (IBAction)onLogout:(id)sender
{
    PFUser *user = [PFUser currentUser];
    
    NSMutableString *message = [[NSMutableString alloc] initWithFormat:@"You're logged in as %@",user[FULL_NAME]];
    [message appendString:@"\nDo you want to logout?"];
    
    [UIAlertView showWithTitle:@"Message"
                       message:message
             cancelButtonTitle:@"No"
             otherButtonTitles:@[@"Logout"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex==1) {
                              [[ABUserManager sharedManager] logout];
                              [[ABKlaus appDelegate] setRootController];
                          }
                      }];
}
@end
