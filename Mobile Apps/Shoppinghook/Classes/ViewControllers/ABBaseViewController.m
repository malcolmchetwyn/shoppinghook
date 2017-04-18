//
//  ABBaseViewController.m
//  Shoppinghook
//
//  Created on 21/03/2014.
//  
//

#import "ABBaseViewController.h"

@interface ABBaseViewController ()

@end

@implementation ABBaseViewController


- (void)setupLocalization {
    
}

- (void)setupUI {
    
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
    
    self.view.backgroundColor = [UIColor flatAsbestosColor];
    
    if ([ABKlaus isIOS7AndHigher]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self setupUI];
    [self setupLocalization];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil)
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isConnected {
    
    if (![[ABReachabilityManager sharedManager] isInternetAvailable]) {
        NSError *err = [NSError errorWithDomain:@"Shoppinghook" code:kPFErrorConnectionFailed userInfo:@{}];
        [ABErrorManager handleError:err];
        return NO;
    }
    return YES;
}

- (void)showActivity
{
    if (self.navigationController)
    {
        self.navigationController.view.userInteractionEnabled = NO;
        //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:NO];
    }
    else if (self.parentViewController.navigationController)
    {
        self.parentViewController.navigationController.view.userInteractionEnabled = NO;
        //[MBProgressHUD showHUDAddedTo:self.parentViewController.navigationController.view animated:NO];
    }
    else
    {
        self.view.userInteractionEnabled = NO;
        //[MBProgressHUD showHUDAddedTo:self.view animated:NO];
    }
}
- (void)hideActivity
{
    if (self.navigationController)
    {
        self.navigationController.view.userInteractionEnabled = YES;
        //[MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:NO];
    }
    else if (self.parentViewController.navigationController)
    {
        self.parentViewController.navigationController.view.userInteractionEnabled = YES;
        //[MBProgressHUD hideAllHUDsForView:self.parentViewController.navigationController.view animated:NO];
    }
    else
    {
        self.view.userInteractionEnabled = YES;
        //[MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    }
}

@end
