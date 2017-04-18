//
//  ABLoginViewController.m
//  Shoppinghook
//
//  Created on 21/03/2014.
//  
//

#import "ABStartViewController.h"
#import "ABSignupStepAViewController.h"
#import "ABSigninViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "ABFriendCollectionViewController.h"

@interface ABStartViewController () <UITextFieldDelegate>{
    
    __weak IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    __weak IBOutlet UIButton *btnFacebook;
    __weak IBOutlet UIButton *btnSignup;
    __weak IBOutlet UIButton *btnLogin;
    
}
- (IBAction)onFacebook:(UIButton *)sender;
- (IBAction)onSignUp:(id)sender;
- (IBAction)onLogin:(id)sender;
@end

@implementation ABStartViewController

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
    [scrollView contentSizeToFit];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Actions

- (IBAction)onFacebook:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    [self showActivity];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            if (!error) {
                
                [ABErrorManager showAlertWithMessage:@"User has canceled login"];
            } else {
                // DuckDuckGo
                NSString *alertText = [FBErrorUtility userMessageForError:error];
                [ABErrorManager showAlertWithMessage:alertText];
            }
            [self hideActivity];
        }
        else if (user.isNew)
        {
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // Store the current user's Facebook ID on the user
                    
                    user[FACEBOOK_ID]=result[@"id"];
                    user[FULL_NAME] = [NSString stringWithFormat:@"%@ %@",result[@"first_name"],result[@"last_name"]];
                    user[CHANNEL]    = user.objectId;
                    user[FACEBOOK_FRIENDS] = @[];
                    
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        
                        [UIAlertView showWithTitle:@"Shoppinghook"
                                           message:@"Do you want to receive push notifications."
                                 cancelButtonTitle:@"Cancel"
                                 otherButtonTitles:@[@"OK" ]
                                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                              
                                              ABAppDelegate *delegate = [ABKlaus appDelegate];
                                              
                                              if (buttonIndex==1) {
                                                  [delegate registerForPushNotifications];
                                              }
                                              ABFriendCollectionViewController *friendVC = [ABFriendCollectionViewController loadFromNib];
                                              friendVC.platform = PlatformFacebook;
                                              friendVC.navigationMode = NavigationModeGoForward;
                                              [self.navigationController pushViewController:friendVC animated:YES];

                                          }];
                        
                        
                        [self hideActivity];
                    }];
                }
            }];
            
            
        } else {
            
            [UIAlertView showWithTitle:@"Shoppinghook"
                               message:@"Do you want to receive push notifications."
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@[@"OK" ]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  
                                  ABAppDelegate *delegate = [ABKlaus appDelegate];
                                  
                                  if (buttonIndex==1) {
                                      [delegate registerForPushNotifications];
                                  }
                                  [[ABKlaus appDelegate] setRootController];
                              }];
            
            [self hideActivity];
        }
    }];
    
    
}

- (IBAction)onSignUp:(id)sender {
    ABSignupStepAViewController *signupViewController = [ABSignupStepAViewController loadFromNib];
    [self.navigationController pushViewController:signupViewController animated:YES];
}

- (IBAction)onLogin:(id)sender {
    ABSigninViewController *signinViewController = [ABSigninViewController loadFromNib];
    [self.navigationController pushViewController:signinViewController animated:YES];
    
}
@end
