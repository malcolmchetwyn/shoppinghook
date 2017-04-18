//
//  ABFriendListViewController.m
//  Shoppinghook
//
//  Created on 27/03/2014.
//  
//

#import "ABFriendListViewController.h"
#import "ABContactTableViewCell.h"
#import "ABCreateGroupViewController.h"
#import "Group.h"
#import "ABActivityManager.h"
#import "ABFeedViewController.h"

@interface ABFriendListViewController () <UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>{
    
    __weak IBOutlet UITableView *tableView;
   
    NSArray *friends;
    NSArray *groups;
    
    NSMutableArray *filteredFriends;
    NSMutableArray *filteredGroups;
    
    NSMutableArray *selectedGroups;
    NSMutableArray *selectedUsers;
}

@end

@implementation ABFriendListViewController

#pragma mark - Get Friends

- (void)getFriends {
    
    [[ABUserManager sharedManager] getUserFriendsWithSuccess:^(NSArray *result) {
        
        friends = [NSArray arrayWithArray:result];
        [tableView reloadData];
        
    } failure:^(NSError *error) {
        [ABErrorManager handleError:error];
        [tableView reloadData];
    }];
}

- (void)getGroups {
    
    [[ABUserManager sharedManager] getGroupsWithSuccess:^(NSArray *objects) {
        groups = [NSArray arrayWithArray:objects];
        [tableView reloadData];
    } failure:^(NSError *error) {
        [ABErrorManager handleError:error];
    }];
}

- (void)addGroup:(id)sender {
    
    [self.navigationController pushViewController:[ABCreateGroupViewController loadFromNib] animated:YES];
}

- (void)onSave:(id)sender {
    
    if (![self isConnected]) {
        return;
    }
    
    NSMutableSet *channels = [NSMutableSet set];
    
    for (PFUser *user in selectedUsers) {
        [channels addObject:user[CHANNEL]];
    }
    
    for (Group *group in selectedGroups) {
        [channels addObjectsFromArray:group.users];
    }
    
    [[ABActivityManager sharedManager] postActivityWithUserIds:[channels allObjects] images:_images];
    
    if ([self.delegate respondsToSelector:@selector(activitySaved)]) {
        [self.delegate activitySaved];
    }
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    NSMutableArray *newControllers = [NSMutableArray arrayWithArray:viewControllers];
    [newControllers removeObject:self];
    
    ABFeedViewController *feedVC = [ABFeedViewController new];
    [newControllers addObject:feedVC];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.navigationController setViewControllers:newControllers];
                     } completion:^(BOOL finished) {
        
                     }];
    
    
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UI

- (void)setupUI {
    
    tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onSave:)];
    
    self.navigationItem.rightBarButtonItem = save;
    
    
}

#pragma mark - VC life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Friends", nil);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getGroups];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getFriends];
    
    selectedUsers = [NSMutableArray new];
    selectedGroups= [NSMutableArray new];
    filteredFriends = [NSMutableArray new];
    filteredGroups  = [NSMutableArray new];
    
    [tableView registerNib:[UINib nibWithNibName:@"ABContactTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"ABContactTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Select Action

- (void)onGroupSelectAction:(UIButton*)sender {
    
    NSUInteger index = sender.tag-1;
    
    Group *group = groups[index];
    
    if ([selectedGroups containsObject:group]) {
        [selectedGroups removeObject:group];
        sender.selected = NO;
    }
    else {
        [selectedGroups addObject:group];
        sender.selected = YES;
    }
    
}

- (void)onFriendSelectAction:(UIButton*)sender {
    
    NSUInteger index = sender.tag-1;
    
    PFUser *user = friends[index];
    
    if ([selectedUsers containsObject:user]) {
        [selectedUsers removeObject:user];
        sender.selected = NO;
    }
    else {
        [selectedUsers addObject:user];
        sender.selected = YES;
    }
}

- (void)onSearchedGroupSelectAction:(UIButton*)sender {
    
    NSUInteger index = sender.tag-1;
    
    Group *group = filteredGroups[index];
    
    if ([selectedGroups containsObject:group]) {
        [selectedGroups removeObject:group];
        sender.selected = NO;
    }
    else {
        [selectedGroups addObject:group];
        sender.selected = YES;
    }
    
}

- (void)onSearchedFriendSelectAction:(UIButton*)sender {
    
    NSUInteger index = sender.tag-1;
    
    PFUser *user = friends[index];
    
    if ([selectedUsers containsObject:user]) {
        [selectedUsers removeObject:user];
        sender.selected = NO;
    }
    else {
        [selectedUsers addObject:user];
        sender.selected = YES;
    }
}


#pragma mark - TableView Data Source & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (aTableView==self.searchDisplayController.searchResultsTableView) {
        if (section==0) {
            return filteredGroups.count;
        }
        else {
            return filteredFriends.count;
        }
    }
    else {
        if (section==0) {
            return groups.count;
        }
        else {
            return friends.count;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return @"Groups";
    }
    else {
        return @"Friends";
    }
}



- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isSearchTable = (aTableView==self.searchDisplayController.searchResultsTableView)?YES:NO;
    
    static NSString *cellIdentifier = @"userCell";
    
    ABContactTableViewCell *cell = (ABContactTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.btnAction.tag = indexPath.row+1;
    
    if (indexPath.section==0) {
        
        Group *group = groups[indexPath.row];
        
        if (isSearchTable) {
            group = filteredGroups[indexPath.row];
            [cell.btnAction addTarget:self
                               action:@selector(onSearchedGroupSelectAction:)
                     forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            [cell.btnAction addTarget:self
                               action:@selector(onGroupSelectAction:)
                     forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.lblTitle.text = [NSString stringWithFormat:@"Group - %@",group.name];
        
        if ([selectedGroups containsObject:group]) {
            cell.btnAction.selected = YES;
        }
        else {
            cell.btnAction.selected = NO;
        }
        
    }
    else {
        
        PFUser *user = friends[indexPath.row];
        
        if (isSearchTable) {
            user = filteredFriends[indexPath.row];
            [cell.btnAction addTarget:self
                               action:@selector(onSearchedFriendSelectAction:)
                     forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [cell.btnAction addTarget:self
                               action:@selector(onFriendSelectAction:)
                     forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.lblTitle.text = [NSString stringWithFormat:@"%@",user[FULL_NAME]];
        

        
        if ([selectedUsers containsObject:user]) {
            cell.btnAction.selected = YES;
        }
        else {
            cell.btnAction.selected = NO;
        }
    }
    
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
    
    NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@",NAME,searchText];
    [filteredGroups removeAllObjects];
    [filteredGroups addObjectsFromArray:[groups filteredArrayUsingPredicate:groupPredicate]];
    
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
    [tableView reloadData];
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
