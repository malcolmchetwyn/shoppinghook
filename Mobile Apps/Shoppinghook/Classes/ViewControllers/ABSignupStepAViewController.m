//
//  ABSignupStepAViewController.m
//  Shoppinghook
//
//  Created on 13/04/2014.
//  
//

#import "ABSignupStepAViewController.h"
#import "ABSignupStepBViewController.h"

#import "ABInputView.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface ABSignupStepAViewController ()<UITextFieldDelegate> {

    UIBarButtonItem *nextItem;
    __weak IBOutlet UITextField *tfName;
    __weak IBOutlet TPKeyboardAvoidingScrollView *scrollView;
}

@end

@implementation ABSignupStepAViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)setupUI {
    
    nextItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(onSignup:)];
    self.navigationItem.rightBarButtonItem = nextItem;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Full Name";

    [scrollView contentSizeToFit];
    
    [self enableDisableNextButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [tfName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITEXTFIELD DELEGATE

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    [self enableDisableNextButton];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self enableDisableNextButton];
    return YES;
}


#pragma mark - Actions

- (BOOL)isValidName:(NSString*)string {
    NSString *regex = @"[a-zA-z]+([ '-][a-zA-Z]+)*$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [test evaluateWithObject:string];
    return isValid;
}

- (void)enableDisableNextButton {
    
    if (tfName.text.length>0) {
        nextItem.enabled = YES;
    }
    else {
        nextItem.enabled = NO;
    }
}

- (void)onSignup:(id)sender {
    
    NSString *name = tfName.text;
    
    if (name.length<4) {
        [ABErrorManager showAlertWithMessage:@"The name must be atleast 4 character long."];
        return;
    }
    
    if (![self isValidName:name]) {
        [ABErrorManager showAlertWithMessage:@"Name can't contain special character"];
        return;
    }
    
    ABSignupStepBViewController *VC = [ABSignupStepBViewController loadFromNib];
    VC.fullName = name;
    [self.navigationController pushViewController:VC animated:YES];
}

@end
