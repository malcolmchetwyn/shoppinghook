//
//  ABFriendRequestViewController.m
//  Shoppinghook
//
//  Created on 15/04/2014.
//  
//

#import "ABFriendRequestViewController.h"
#import "ABFriendCollectionViewController.h"
#import "ABFriendCell.h"

@interface ABFriendRequestViewController () {
    
    NSMutableArray *requests;
    NSMutableArray *users;
    
    NSMutableArray *acceptedUsers;
    
    IBOutlet UITableView *tableView;
    
}

@end

@implementation ABFriendRequestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Friend Requests";
        acceptedUsers = [NSMutableArray new];
    }
    return self;
}

- (void)setupUI {
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getRequests) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:self.refreshControl];
    
    tableView.tableFooterView = [UIView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tableView registerNib:[UINib nibWithNibName:@"ABFriendCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userCell2"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:FRIENDS_REQUESTS_REFRESHED object:nil];
    
    [self getRequests];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FRIENDS_REQUESTS_REFRESHED object:nil];
}

- (void)reload:(id)sender {
    [self getRequests];
}

#pragma mark - Requests

- (void)getRequests {
    
    [[ABPushManager sharedManager] resetFriendRequestCount];
    
    [self showActivity];
    
    [[ABUserManager sharedManager] getFriendRequestsWithSuccess:^(NSArray *fRequests) {
        
        if (fRequests.count>0)
        {
            requests = [NSMutableArray arrayWithArray:fRequests];
            NSArray *usersIds = [fRequests valueForKey:FROM_USER_ID];
            
            [[ABUserManager sharedManager] getUsersWithIds:usersIds success:^(NSArray *allUsers) {
                users = nil;
                users = [[NSMutableArray alloc] initWithArray:allUsers];
                [tableView reloadData];
                
                [self hideActivity];
                [self.refreshControl endRefreshing];
                
            } failure:^(NSError *aError) {
                
                [ABErrorManager handleError:aError];
                [self hideActivity];
                [self.refreshControl endRefreshing];
            }];
        }
        else
        {
            [self hideActivity];
            [self.refreshControl endRefreshing];
        }
        
    } failure:^(NSError *error) {
        
        [self hideActivity];
        [ABErrorManager handleError:error];
    }];
}

#pragma mark - Actions

- (void)deleteSelectedRecordsFromTable
{
    NSMutableArray *holdUsers = [NSMutableArray arrayWithArray:users];
    [holdUsers removeObjectsInArray:acceptedUsers];
    users = [[NSMutableArray alloc] initWithArray:holdUsers];
    [acceptedUsers removeAllObjects];
    [tableView reloadData];
    
    
    
    
}

- (void)addFriends:(id)sender
{
    if (![self isConnected]) {
        return;
    }
    
    NSArray *ids = [acceptedUsers valueForKey:CHANNEL];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K in %@",FROM_USER_ID,ids];
    __block NSArray *acceptedRequests = [requests filteredArrayUsingPredicate:predicate];
    
    [requests removeObjectsInArray:acceptedRequests];
    [[ABUserManager sharedManager] addFriend:acceptedUsers[0]];
    [self deleteSelectedRecordsFromTable];
    
    [[ABUserManager sharedManager] acceptRequests:acceptedRequests
                                          success:^(NSArray *result) {
        
                                          } failure:^(NSError *error) {
                                              [self hideActivity];
                                              [ABErrorManager handleError:error];
                                          }];
}

- (void)onSelectAction:(UIButton*)_button {
    
    NSUInteger tag = _button.tag-1;
    
    PFUser *user = users[tag];
    [acceptedUsers addObject:user];
    
    [self addFriends:nil];
}

- (void)onSkip:(id)sender
{
    
    ABFriendCollectionViewController *parent = (ABFriendCollectionViewController*)self.parentViewController;
    
    if (parent.navigationMode==NavigationModeGoForward) {
        [[ABKlaus appDelegate] setRootController];
    }
    else {
    if (self.parentViewController.navigationController)
    {
        [self.parentViewController.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    }
}


#pragma mark - TableView Data Source & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return users.count;

}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"userCell2";
    
    ABFriendCell *cell = (ABFriendCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell.btnAction setTitle:@"Accept" forState:UIControlStateNormal];
    [cell.btnAction setTitle:@"Cancel" forState:UIControlStateSelected];
    
    PFUser *user = users[indexPath.row];

    
    cell.lblTitle.text = [NSString stringWithFormat:@"%@",user[FULL_NAME]];
    cell.btnAction.hidden = NO;
    
    cell.btnAction.tag = indexPath.row+1;
    
        [cell.btnAction addTarget:self
                           action:@selector(onSelectAction:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    if ([acceptedUsers containsObject:user]) {
        cell.btnAction.selected = YES;
    }
    else {
        cell.btnAction.selected = NO;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        
        [tableView beginUpdates];
        
        PFUser *user = users[indexPath.row];
        
        [users removeObject:user];
        
        NSArray *ids = @[user[CHANNEL]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K in %@",FROM_USER_ID,ids];
        NSArray *toDelete = [requests filteredArrayUsingPredicate:predicate];
        
        [PFObject deleteAllInBackground:toDelete];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
    }
}


@end
