//
//  ABHomeViewController.m
//  Shoppinghook
//
//  Created on 25/03/2014.
//  
//

#import "ABHomeViewController.h"
#import "ABFriendListViewController.h"
#import "ABDataCaptureViewController.h"
#import "ABSettingsViewController.h"

@interface ABHomeViewController ()

- (IBAction)onFriends:(UIButton *)sender;
- (IBAction)onSettings:(id)sender;

@end

@implementation ABHomeViewController

- (void)setupUI {
    
//    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", nil) style:UIBarButtonItemStylePlain target:self action:@selector(logOut:)];
//    
//    self.navigationItem.rightBarButtonItem = logoutItem;
    
}

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
    
    self.navigationItem.title = @"Home";
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser[FACEBOOK_ID]) {
        
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
         {
             if (!error)
             {
                 // Do Nothing - Session is Valid
             }
             else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"])
             {
                 [ABErrorManager showAlertWithMessage:@"Your Facebook session has expired. Please Login again"];
                 [self logOut:nil];
             }
             else
             {
                 NSLog(@"Some other error: %@", error);
             }
         }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void) logOut:(id)sender {
    [PFQuery clearAllCachedResults];
    [PFUser logOut];
    [[ABKlaus appDelegate] setRootController];
}

- (IBAction)onFriends:(UIButton *)sender {
    [self.navigationController pushViewController:[ABDataCaptureViewController loadFromNib] animated:YES];
    
    //[self.navigationController pushViewController:[ABFriendListViewController loadFromNib] animated:YES];
}

- (IBAction)onSettings:(id)sender {
    
    [self.navigationController pushViewController:[ABSettingsViewController loadFromNib] animated:YES];
}
@end
