//
//  ABSignupViewController.m
//  Shoppinghook
//
//  Created on 23/03/2014.
//  
//

#import "ABSignupStepBViewController.h"
#import "ABFriendCollectionViewController.h"
#import "ABCountryViewController.h"
#import "ABWebViewController.h"

#import "ABInputView.h"
#import "ABCountryService.h"

@interface ABSignupStepBViewController () <UITextFieldDelegate,CountrySelectionProtocol>{
    
    NSMutableArray *userValues;
    ABInputView *viewEmail;
    ABInputView *viewPassword;
    ABInputView *viewTelephone;
    
    __weak IBOutlet UIView *viewServices;
    __weak IBOutlet UIButton *btnTerms;
    __weak IBOutlet UIButton *btnPolicy;
    
    
    NSDictionary *selectedCountry;
    
    UIButton *btnCountry;
    
    UIBarButtonItem *joinBarItem;
    
}
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

- (IBAction)onTermsOfService:(id)sender;
- (IBAction)onPrivacyPolicy:(id)sender;

@end

@implementation ABSignupStepBViewController

#pragma mark - LOCALIZATION

-(void)setupLocalization {

    viewEmail.lblTitle.text         = NSLocalizedString(@"email", nil);
    viewPassword.lblTitle.text      = NSLocalizedString(@"password", nil);
    viewTelephone.lblTitle.text     = NSLocalizedString(@"Mobile", nil);
    
    viewEmail.tfValue.placeholder = @"example@yahoo.com";
    viewPassword.tfValue.placeholder = @"atleast 8 characters";
    viewTelephone.tfValue.placeholder = nil;
}


#pragma mark - UI

- (void)setupUI {
    
    joinBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onSignup:)];
    self.navigationItem.rightBarButtonItem = joinBarItem;
    
    CGRect rect = CGRectZero;
    CGFloat yAxis = 18.0;
    
    viewEmail     = [ABInputView loadFromNib];
    viewEmail.tfValue.tag = 1;
    viewEmail.tfValue.delegate = self;
    viewEmail.tfValue.keyboardType = UIKeyboardTypeEmailAddress;
    rect = viewEmail.frame;
    rect.origin.y = yAxis;
    viewEmail.frame = rect;
    
    yAxis+=rect.size.height;
    
    viewPassword  = [ABInputView loadFromNib];
    viewPassword.tfValue.tag = 2;
    viewPassword.tfValue.delegate = self;
    viewPassword.tfValue.secureTextEntry = YES;
    rect = viewPassword.frame;
    rect.origin.y = yAxis;
    viewPassword.frame = rect;
    
    yAxis+=rect.size.height;
    
    viewTelephone = [ABInputView loadFromNib];
    viewTelephone.tfValue.tag = 3;
    viewTelephone.tfValue.delegate = self;
    viewTelephone.tfValue.keyboardType = UIKeyboardTypePhonePad;
    [viewTelephone.tfValue setLeftViewMode:UITextFieldViewModeAlways];
    
    btnCountry = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCountry.frame = CGRectMake(0, 1, 60, 28);
    btnCountry.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    [btnCountry setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnCountry.titleLabel.font = viewTelephone.tfValue.font;
    [btnCountry addTarget:self action:@selector(goToCountries:) forControlEvents:UIControlEventTouchUpInside];

    
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if (countryCode.length>2) {
        countryCode = [countryCode substringToIndex:1];
    }
    
    viewTelephone.tfValue.leftView = btnCountry;
    
    selectedCountry = [[ABCountryService service] countryForCountryCode:countryCode];
    NSString *dialingCode = [NSString stringWithFormat:@"%@ %@",selectedCountry[CODE],selectedCountry[DIAL_CODE]];
    [btnCountry setTitle:dialingCode forState:UIControlStateNormal];
    
    rect = viewTelephone.frame;
    rect.origin.y = yAxis;
    viewTelephone.frame = rect;
    
    yAxis+=rect.size.height;
    
    [self.scrollView addSubview:viewEmail];
    [self.scrollView addSubview:viewPassword];
    [self.scrollView addSubview:viewTelephone];
    
}

#pragma mark - VC Life Cycle

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
    
    self.navigationItem.title = @"Signup";
    
    [self.scrollView contentSizeToFit];
    
    [self.scrollView bringSubviewToFront:viewServices];
    
    userValues = [@[self.fullName,@"",@"",@""] mutableCopy];
    
    //[viewTelephone.tfValue becomeFirstResponder];
    //[viewEmail.tfValue becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [viewEmail.tfValue becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)goToCountries:(id)sender {
    
    ABCountryViewController *vc = [[ABCountryViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) enableDisbaleJoinButton {
    BOOL empty = NO;
    for (NSString *value in userValues) {
        if ([value isEmpty]) {
            empty = YES;
            break;
        }
    }
    if (empty) {
        joinBarItem.enabled = NO;
    }
    else{
        joinBarItem.enabled = YES;
    }
}

- (void)onSignup:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![self isConnected]) {
        return;
    }
    
    // Valid Email
    
    if (![ABKlaus isValidEmail:userValues[1]]) {
        [ABErrorManager showAlertWithMessage:NSLocalizedString(@"valid_email", nil)];
        return;
    }
    
    
    NSString *numStr = userValues[3];
    NSRange range = [numStr rangeOfString:@"^0*" options:NSRegularExpressionSearch];
    NSString *result = [numStr stringByReplacingCharactersInRange:range withString:@""];
    
    [userValues replaceObjectAtIndex:3 withObject:result];
    viewTelephone.tfValue.text = result;
    
    // Empty
    
    BOOL empty = NO;
    for (int index = 0; index<userValues.count; index++) {
        if (index==1) {
            continue;
        }
        NSString *string = userValues[index];
        if ([string isEmpty]) {
            empty = YES;
            break;
        }
    }
    
    if (empty) {
        [ABErrorManager showAlertWithMessage:NSLocalizedString(@"empty_fields", nil)];
        return;
    }
    
    NSString *password = userValues[2];
    
    if (password.length<8) {
        [ABErrorManager showAlertWithMessage:NSLocalizedString(@"password_length", nil)];
        return;
    }
    
    NSString *phoneNo = [NSString stringWithFormat:@"%@%@",selectedCountry[DIAL_CODE],userValues[3]];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:PHONE_NO equalTo:phoneNo];
    
    [self showActivity];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (object) {
            
            [self hideActivity];
            
            NSString *message = [NSString stringWithFormat:@"This phone no. is already associated with %@",object[FULL_NAME]];
            [ABErrorManager showAlertWithMessage:message];
        }
        else {
            PFUser *user = [PFUser user];
            
            user[FULL_NAME] = userValues[0];
            
            user.email       = userValues[1];
            user.username    = userValues[1];
            user.password    = userValues[2];
            user[PHONE_NO]   = phoneNo;
            user[FACEBOOK_FRIENDS] = @[];
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (!error) {
                    
                    user[CHANNEL] = user.objectId;
                    [user saveInBackground];
                    
                    
                    [UIAlertView showWithTitle:@"Shoppinghook"
                                       message:@"Do you want to receive push notifications."
                             cancelButtonTitle:@"Cancel"
                             otherButtonTitles:@[@"OK"]
                                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                          
                                          ABAppDelegate *delegate = [ABKlaus appDelegate];
                                          
                                          if (buttonIndex==1) {
                                              [delegate registerForPushNotifications];
                                          }
                                          ABFriendCollectionViewController *friendVC = [ABFriendCollectionViewController loadFromNib];
                                          friendVC.platform = PlatformPhoneBook;
                                          friendVC.navigationMode = NavigationModeGoForward;
                                          [self.navigationController pushViewController:friendVC animated:YES];
                                          
                                      }];
                    
                    
                }
                else {
                    [ABErrorManager handleError:error];
                }
                [self hideActivity];
            }];
        }
    }];
}

- (IBAction)onPrivacyPolicy:(UIButton *)sender {
    ABWebViewController *webVC = [ABWebViewController loadFromNib];
    webVC.urlString = SHOOK_POLICY_URL_STRING;
    webVC.titleString = @"Privacy Policy";
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)onTermsOfService:(id)sender {
    ABWebViewController *webVC = [ABWebViewController loadFromNib];
    webVC.urlString = SHOOK_TERMS_URL_STRING;
    webVC.titleString = @"Terms of Service";
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - UITEXTFIELD DELEGATE

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    [userValues replaceObjectAtIndex:textField.tag withObject:textField.text];
    [self enableDisbaleJoinButton];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [userValues replaceObjectAtIndex:textField.tag withObject:textField.text];
    [self enableDisbaleJoinButton];
    return YES;
}

#pragma mark - CountrySelectionDelegate

- (void)didSelectedTheCountry:(NSDictionary*)_country {
    selectedCountry = _country;
    NSString *dialingCode = [NSString stringWithFormat:@"%@ %@",selectedCountry[CODE],selectedCountry[DIAL_CODE]];
    [btnCountry setTitle:dialingCode forState:UIControlStateNormal];
}

@end
