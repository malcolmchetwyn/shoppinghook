//
//  ABPolicyAndTermsViewController.m
//  Shoppinghook
//
//  Created on 09/04/2014.
//  
//

#import "ABPolicyAndTermsViewController.h"
#import "ABWebViewController.h"

@interface ABPolicyAndTermsViewController ()
- (IBAction)onPrivacyPolicy:(UIButton *)sender;
- (IBAction)onTermsOfService:(UIButton*)sender;

@end

@implementation ABPolicyAndTermsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Privacy and Terms of Service";
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
@end
