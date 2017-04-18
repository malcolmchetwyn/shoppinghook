//
//  ABCreateGroupViewController.m
//  Shoppinghook
//
//  Created on 31/03/2014.
//  
//

#import "ABCreateGroupViewController.h"
#import "ABContactTableViewCell.h"

@interface ABCreateGroupViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITextFieldDelegate>{
    
    NSMutableArray *allFriends;
    NSMutableArray *filteredFriends;
    NSMutableArray *selectedFriends;
    
    BOOL isSearchOn;
    
    __weak IBOutlet UILabel *lblGroup;
    __weak IBOutlet UITextField *tfGroupName;
    __weak IBOutlet UITableView *tableView;
}

@end

@implementation ABCreateGroupViewController


#pragma mark - Get Friends

- (void)getFriends {
    
    [[ABUserManager sharedManager] getUserFriendsWithSuccess:^(NSArray *result) {
        
        allFriends = [NSMutableArray arrayWithArray:result];
        [tableView reloadData];
        
    } failure:^(NSError *error) {
        [ABErrorManager handleError:error];
        [tableView reloadData];
    }];
}

#pragma mark - actions

- (void)saveGroup:(id)sender {
    
    if (![self isConnected]) {
        return;
    }
    
    if (tfGroupName.text.length==0) {
        [ABErrorManager showAlertWithMessage:@"Enter a group name."];
        return;
    }
    
    if (selectedFriends.count>0) {
        
        [[ABUserManager sharedManager] addGroupWithName:tfGroupName.text
                                                friends:selectedFriends
                                                success:^(NSArray *groups) {
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                } failure:^(NSError *error) {
                                                    [ABErrorManager handleError:error];
                                                }];
    }
    else {
        [ABErrorManager showAlertWithMessage:@"Select At least one friend."];
    }
}

#pragma mark - setup UI

- (void)setupUI {
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveGroup:)];
    
    self.navigationItem.rightBarButtonItem = save;
    
    tableView.tableFooterView = [UIView new];
    
}

#pragma mark - VC life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Add Group";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    selectedFriends=[NSMutableArray array];
    filteredFriends = [NSMutableArray array];
    allFriends = [NSMutableArray array];
    
    [self getFriends];
    
    
    [tableView registerNib:[UINib nibWithNibName:@"ABContactTableViewCell" bundle:[NSBundle mainBundle]]
    forCellReuseIdentifier:@"userCell"];
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"ABContactTableViewCell" bundle:[NSBundle mainBundle]]
                                              forCellReuseIdentifier:@"userCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)onSeachedSelectAction:(UIButton*)_button {
    
    NSUInteger tag = _button.tag-1;
    
    PFUser *user = filteredFriends[tag];
    
    if ([selectedFriends containsObject:user]) {
        
        [selectedFriends removeObject:user];
        _button.selected = NO;
        
    }
    else {
        
        [selectedFriends addObject:user];
        _button.selected = YES;
        
    }
    
}

- (void)onSelectAction:(UIButton*)_button {
    
    NSUInteger tag = _button.tag-1;
    
    PFUser *user = allFriends[tag];
    
    if ([selectedFriends containsObject:user]) {
        
        [selectedFriends removeObject:user];
        _button.selected = NO;
        
    }
    else {
        
        [selectedFriends addObject:user];
        _button.selected = YES;
        
    }
    
}

#pragma mark - TableView Data Source & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (aTableView==tableView) {
        return allFriends.count;
    }
    else {
        return filteredFriends.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"userCell";
    
    BOOL isSearchTable = (aTableView==self.searchDisplayController.searchResultsTableView)?YES:NO;
    
    ABContactTableViewCell *cell = (ABContactTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    PFUser *user = allFriends[indexPath.row];
    
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
    
    if ([selectedFriends containsObject:user]) {
        cell.btnAction.selected = YES;
    }
    else {
        cell.btnAction.selected = NO;
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
        [results addObjectsFromArray:[allFriends filteredArrayUsingPredicate:resultPredicate]];
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
