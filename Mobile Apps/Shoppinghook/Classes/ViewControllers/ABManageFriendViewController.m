//
//  ABManageFriendViewController.m
//  Shoppinghook
//
//  Created on 09/04/2014.
//  
//

#import "ABManageFriendViewController.h"
#import "ABFriendCell.h"

@interface ABManageFriendViewController () <UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>{
    
    NSArray *friends;
    NSMutableArray *filteredFriends;
    NSMutableArray *selectedUsers;
    
    UIBarButtonItem *nextItem;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ABManageFriendViewController

#pragma mark - Get Friends

- (void)getFriends {
        
    [[ABUserManager sharedManager] getUserFriendsWithSuccess:^(NSArray *result) {
        
        friends = [NSArray arrayWithArray:result];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [ABErrorManager handleError:error];
        [self.tableView reloadData];
    }];
}

#pragma mark - UI

- (void)setupUI {
    
    nextItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil)
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(onNext:)];
    
    self.navigationItem.rightBarButtonItem = nextItem;
    
    self.tableView.tableFooterView = [UIView new];
    
    [self enableDisableNextItem];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Manage Friends";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getFriends];
    
    selectedUsers = [NSMutableArray new];
    filteredFriends = [NSMutableArray new];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ABFriendCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userCell2"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"ABFriendCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userCell2"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)enableDisableNextItem {
    if (selectedUsers.count>0) {
        nextItem.enabled = YES;
    }
    else {
        nextItem.enabled = NO;
    }
}

- (void)onNext:(id)sender {
    
    if (![self isConnected]) {
        return;
    }
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (selectedUsers.count>0) {
        
        NSMutableArray *selectedIds = [NSMutableArray new];
        
        for (PFUser *user in selectedUsers) {
            [selectedIds addObject:user[CHANNEL]];
        }
        [currentUser removeObjectsInArray:selectedIds forKey:FACEBOOK_FRIENDS];
        
        PFQuery *fromQuery = [PFQuery queryWithClassName:@"UserActivity"];
        [fromQuery whereKey:FROM_USER_ID containedIn:selectedIds];
        [fromQuery whereKey:TO_USER_ID equalTo:currentUser[CHANNEL]];
        [fromQuery whereKey:STATUS equalTo:FRIEND];
        
        PFQuery *toQuery = [PFQuery queryWithClassName:@"UserActivity"];
        [fromQuery whereKey:FROM_USER_ID equalTo:currentUser[CHANNEL]];
        [fromQuery whereKey:TO_USER_ID containedIn:selectedIds];
        [fromQuery whereKey:STATUS equalTo:FRIEND];
        
        
        PFQuery *query = [PFQuery orQueryWithSubqueries:@[fromQuery,toQuery]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            
            [currentUser saveInBackground];
            
            [PFObject deleteAllInBackground:results block:^(BOOL succeeded, NSError *error) {
                
                for (PFUser *user in selectedUsers) {
                    [[ABUserManager sharedManager] removeFriend:user];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        }];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onSeachedSelectAction:(UIButton*)_button {
    
    NSUInteger tag = _button.tag-1;
    
    PFUser *user = filteredFriends[tag];
    
    if ([selectedUsers containsObject:user]) {
        
        [selectedUsers removeObject:user];
        _button.selected = NO;
        
    }
    else {
        
        [selectedUsers addObject:user];
        _button.selected = YES;
        
    }
    
    [self enableDisableNextItem];
    
}

- (void)onSelectAction:(UIButton*)_button {
    
    NSUInteger tag = _button.tag-1;
    
    PFUser *user = friends[tag];
    
    if ([selectedUsers containsObject:user]) {
        
        [selectedUsers removeObject:user];
        _button.selected = NO;
        
    }
    else {
        
        [selectedUsers addObject:user];
        _button.selected = YES;
        
    }
    
    [self enableDisableNextItem];
    
}

#pragma mark - TableView Data Source & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (aTableView==self.tableView) {
        return friends.count;
    }
    else {
        return filteredFriends.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"userCell2";
    
    BOOL isSearchTable = (aTableView==self.searchDisplayController.searchResultsTableView)?YES:NO;
    
    ABFriendCell *cell = (ABFriendCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    PFUser *user = friends[indexPath.row];
    
    if (isSearchTable) {
        user = filteredFriends[indexPath.row];
    }
    
    cell.lblTitle.text = [NSString stringWithFormat:@"%@",user[FULL_NAME]];
    cell.btnAction.hidden = NO;
    
    cell.btnAction.tag = indexPath.row+1;
    
    if (isSearchTable)
    {
        [cell.btnAction addTarget:self
                           action:@selector(onSeachedSelectAction:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [cell.btnAction addTarget:self
                           action:@selector(onSelectAction:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([selectedUsers containsObject:user]) {
        cell.btnAction.selected = YES;
    }
    else {
        cell.btnAction.selected = NO;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Search Display Controller Delegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    
    NSMutableSet *results = [NSMutableSet set];
    NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
    
    for (NSString *term in searchTerms) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"firstName BEGINSWITH[cd] %@ OR lastName BEGINSWITH[cd] %@ OR fullName BEGINSWITH[cd] %@",term,term,term];
        [results addObjectsFromArray:[friends filteredArrayUsingPredicate:resultPredicate]];
    }
    
    [filteredFriends removeAllObjects];
    [filteredFriends addObjectsFromArray:[results allObjects]];
    
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString *str = searchBar.text;
    [self.searchDisplayController setActive:NO animated:YES];
    [searchBar setText:str];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.tableView reloadData];
    [self.searchDisplayController setActive:NO animated:YES];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    //if we only try and resignFirstResponder on textField or searchBar,
    //the keyboard will not dissapear (at least not on iPad)!
    [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:self.searchDisplayController.searchBar afterDelay: 0.1];
    return YES;
}

@end
