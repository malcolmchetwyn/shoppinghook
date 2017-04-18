//
//  ABFBFriendsViewController.m
//  Shoppinghook
//
//  Created on 25/03/2014.
//  
//

#import "ABFBFriendsViewController.h"

@interface ABFBFriendsViewController () {
    
    __weak IBOutlet UITableView *tableView;
    
    NSArray *allUsers;
    NSArray *appUsers;
    NSArray *newUsers;
    
    NSMutableArray *selectedAppUsers;
    NSMutableArray *selectedNewUsers;
    
    BOOL appUsersExist;
}

@end

@implementation ABFBFriendsViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
