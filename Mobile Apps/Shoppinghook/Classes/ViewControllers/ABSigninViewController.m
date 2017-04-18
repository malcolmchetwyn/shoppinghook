//
//  ABSigninViewController.m
//  Shoppinghook
//
//  Created on 13/04/2014.
//  
//

#import "ABSigninViewController.h"

@interface ABSigninViewController () {
    
    NSMutableArray *userValues;
    __weak IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    __weak IBOutlet UITextField *tfEmail;
    __weak IBOutlet UITextField *tfPassword;
    __weak IBOutlet UIButton *btnLogin;
    __weak IBOutlet UIButton *btnForgotPassword;
}
- (IBAction)onLogin:(id)sender;
- (IBAction)onForgotPassword:(id)sender;

@end

@implementation ABSigninViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupUI {
    
    UIView *leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    UIView *leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    
    tfEmail.leftView = leftView1;
    tfEmail.leftViewMode = UITextFieldViewModeAlways;
    
    tfPassword.leftView = leftView2;
    tfPassword.leftViewMode = UITextFieldViewModeAlways;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Login";
    
    [scrollView contentSizeToFit];
    
    userValues = [@[@"",@""] mutableCopy];
    [self enableDisbaleLoginButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [tfEmail becomeFirstResponder];
}

#pragma mark - UITEXTFIELD DELEGATE

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    [userValues replaceObjectAtIndex:textField.tag withObject:textField.text];
    [self enableDisbaleLoginButton];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [userValues replaceObjectAtIndex:textField.tag withObject:textField.text];
    [self enableDisbaleLoginButton];
    return YES;
}

#pragma mark  - Actions

- (void)enableDisbaleLoginButton {
    
    NSString *email = userValues[0];
    NSString *password = userValues[1];
    
    if (email.length && password.length) {
        btnLogin.enabled = YES;
        btnLogin.alpha = 1.0;
    }
    else{
        btnLogin.enabled = NO;
        btnLogin.alpha = 0.5;
    }
}

- (IBAction)onLogin:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![self isConnected]) {
        return;
    }
    
    
    // Empty Check
    BOOL empty = NO;
    for (NSString *string in userValues) {
        if ([string isEmpty]) {
            empty = YES;
            break;
        }
    }
    if (empty) {
        [ABErrorManager showAlertWithMessage:NSLocalizedString(@"empty_fields", nil)];
        return;
    }
    
    // Valid Email
    
    if (![ABKlaus isValidEmail:userValues[0]]) {
        [ABErrorManager showAlertWithMessage:NSLocalizedString(@"valid_email", nil)];
        return;
    }
    
    [self showActivity];
    
    [PFUser logInWithUsernameInBackground:userValues[0]
                                 password:userValues[1]
                                    block:^(PFUser *user, NSError *error) {
                                        
                                        [self hideActivity];
                                        if (user)
                                        {
                                            [UIAlertView showWithTitle:@"Shoppinghook"
                                                               message:@"Do you want to receive push notifications."
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@[@"OK" ]
                                                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                  
                                                                  ABAppDelegate *delegate = [ABKlaus appDelegate];
                                                                
                                                                  if (buttonIndex==1) {
                                                                      [delegate registerForPushNotifications];
                                                                  }
                                                                  [delegate setRootController];
                                                                }];
                                            
                                        }
                                        else
                                        {
                                            if ([error code]==101)
                                            {
                                                [ABErrorManager showAlertWithMessage:NSLocalizedString(@"wrong_credentials", nil)];
                                            }
                                            else
                                            {
                                                [ABErrorManager handleError:error];
                                            }
                                        }
                                    }];
    
}

- (IBAction)onForgotPassword:(id)sender {
    [self.view endEditing:YES];
    
    [UIAlertView showWithTitle:@"Enter your Email"
                       message:nil
                         style:UIAlertViewStylePlainTextInput
             cancelButtonTitle:@"Cancel"
             otherButtonTitles:@[@"OK"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex==1) {
                              NSString *email = [alertView textFieldAtIndex:0].text;
                              if (![email isEmpty]) {
                                  if (![self isConnected]) {
                                      return;
                                  }
                                  
                                  [self forgotPasswordWithEmail:email];
                              }
                          }
                          
                          
                      }];
}

- (void)forgotPasswordWithEmail:(NSString*)_email {
    
    [PFUser requestPasswordResetForEmailInBackground:_email block:^(BOOL succeeded, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (error) {
            [ABErrorManager handleError:error];
        }
        else {
            [ABErrorManager showAlertWithMessage:@"Your password reset link is sent to your email"];
        }
    }];
}

@end
