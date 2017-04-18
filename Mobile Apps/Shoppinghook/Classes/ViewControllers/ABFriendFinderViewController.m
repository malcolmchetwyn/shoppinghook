//
//  ABContactsViewController.m
//  Shoppinghook
//
//  Created on 25/03/2014.
//  
//

#import "ABFriendFinderViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "ABFriendCollectionViewController.h"
#import "ABContactTableViewCell.h"
#import "ABUserSectionHeaderView.h"

static FBFrictionlessRecipientCache* ms_friendCache;

@interface ABFriendFinderViewController () <UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate>{
    
    __weak IBOutlet UITableView *tableView;
    
    NSArray *allUsers;
    NSArray *appUsers;
    NSArray *newUsers;
    
    NSMutableArray *filteredAppUsers;
    NSMutableArray *filteredNewUsers;
    
    NSMutableArray *selectedAppUsers;
    NSMutableArray *selectedNewUsers;
    
    BOOL appUsersExist;
    
}

@end

@implementation ABFriendFinderViewController

#pragma mark - Requests

- (void)getContacts {
    
    if (self.platform==PlatformPhoneBook)
    {
        [self getAllPhoneContacts];
    }
    else
    {
        [self getFriendsFromFB];
    }
}

- (void) getConatctsFromAddressBook:(ABAddressBookRef)addressBook {
    
    NSMutableArray *allContacts = [NSMutableArray new];
    
    CFArrayRef records = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSArray *contacts = (__bridge NSArray*)records;
    CFRelease(records);
    
    for(int i = 0; i < contacts.count; i++) {
        ABRecordRef person = (__bridge ABRecordRef)[contacts objectAtIndex:i];
        
        NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonFirstNameProperty);
        firstName = [firstName stringByEscapingNullValues];
        firstName=firstName?firstName:@"";
        NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonLastNameProperty);
        lastName = [lastName stringByEscapingNullValues];
        lastName = lastName?lastName:@"";
        
        // Phone Number
        NSString *phoneNumber = nil;
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumbers) > 0) {
            phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSLog(@"phoneNUmber %@",phoneNumber);
        }
        
        CFRelease(phoneNumbers);
        
        NSString *currentUserPhoneNo = [PFUser currentUser][PHONE_NO];
        
        if (phoneNumber && ![phoneNumber isEmpty] && ![phoneNumber isEqualToString:currentUserPhoneNo]) {
            
            if ([firstName isEmpty] && [lastName isEmpty]) {
                firstName = phoneNumber;
            }
            
            NSDictionary *conatctDict = @{FIRST_NAME:firstName,LAST_NAME:lastName,PHONE_NO:phoneNumber};
            [allContacts addObject:conatctDict];
        }
    }
    
    if (allContacts.count>0) {
        allUsers = [NSArray arrayWithArray:allContacts];
        [self partitionUsers];
    }
    else {
        allUsers = nil;
    }
}

- (void) getAllPhoneContacts
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            //start importing contacts
            [self getConatctsFromAddressBook:addressBookRef];
            
            if(addressBookRef) CFRelease(addressBookRef);
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        // start importing contacts
        [self getConatctsFromAddressBook:addressBookRef];
        
        if(addressBookRef) CFRelease(addressBookRef);
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Access"
                                                        message:@"Go to phone setting and grant us access to your contacts now!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        if(addressBookRef) CFRelease(addressBookRef);
    }
}

#pragma mark - Get Friends from fb

- (void)getFriendsFromFB {
    
    [self showActivity];
    
    [[ABUserManager sharedManager] fbFriendsWithSuccess:^(NSArray *friends) {
        
        allUsers = [NSArray arrayWithArray:friends];
        [self hideActivity];
        [self partitionUsers];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - reload

- (void)reload:(id)sender {
    [self partitionUsers];
}

#pragma mark - Partition Users

- (void) partitionUsers {
    
    if (![[ABReachabilityManager sharedManager] isInternetAvailable]) {
        
        appUsersExist = NO;
        newUsers = allUsers;
        [tableView reloadData];
        [self hideActivity];
    }
    else{
        // Find All the existing users based on phoneno or fbid
        // Remove the conatcts which are already on S.Hook
        // I want to kill myself now that fried requests are also a part of this long story
        // Also Remove the existing friends from existing S.Hook contacts
        
        PFUser *current = [PFUser currentUser];
        
        [self showActivity];
        
        NSMutableArray *uniqueIdentifier = [NSMutableArray array];
        
        NSString *uniqueKey = nil;
        if (self.platform==PlatformPhoneBook) {
            uniqueKey = PHONE_NO;
        }
        else {
            uniqueKey = FACEBOOK_ID;
        }
        
        for (NSDictionary *dict in allUsers) {
            [uniqueIdentifier addObject:dict[uniqueKey]];
        }
        
        PFQuery *query = [PFUser query];
        [query whereKey:uniqueKey containedIn:uniqueIdentifier];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error)
            {
                
                if (objects.count>0) {
                    
                    NSMutableArray *users = [NSMutableArray arrayWithArray:objects];
                    
                    // Remove existing friends as well if required
                    
                    NSMutableSet *friendsAndRequests = [NSMutableSet set];
                    
                    [friendsAndRequests addObjectsFromArray:[[ABUserManager sharedManager] userIdsOfFriendRequests]];
                    [friendsAndRequests addObjectsFromArray:[[ABUserManager sharedManager] userIdsOfSentFriendRequests]];
                    [friendsAndRequests addObjectsFromArray:current[FACEBOOK_FRIENDS]];
                    
                   // NSArray *friendIds = current[FACEBOOK_FRIENDS];
                    NSArray *friendIds = [friendsAndRequests allObjects];
                    
                    NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"%K in %@",CHANNEL,friendIds];
                    
                    NSArray *friends = [users filteredArrayUsingPredicate:friendPredicate];
                    
                    if (friends.count>0) {
                        [users removeObjectsInArray:friends];
                    }
                    
                    if (users.count>0) {
                        
                        appUsersExist = YES;
                        appUsers = [NSArray arrayWithArray:users];
                        
                        NSMutableArray *existingAppUserUniqueIdentifiers = [NSMutableArray array];
                        
                        for (PFUser *user in objects) {
                            [existingAppUserUniqueIdentifiers addObject:user[uniqueKey]];
                        }
                        
                        
                        NSMutableArray *temp = [NSMutableArray arrayWithArray:allUsers];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K in %@",uniqueKey,existingAppUserUniqueIdentifiers];
                        NSArray *toRemove = [temp filteredArrayUsingPredicate:predicate];
                        
                        [temp removeObjectsInArray:toRemove];
                        
                        newUsers = [NSArray arrayWithArray:temp];
                        
                    }
                    else {
                        appUsersExist = NO;
                        
                        NSMutableArray *existingAppUserUniqueIdentifiers = [NSMutableArray array];
                        
                        for (PFUser *user in objects) {
                            [existingAppUserUniqueIdentifiers addObject:user[uniqueKey]];
                        }
                        
                        
                        NSMutableArray *temp = [NSMutableArray arrayWithArray:allUsers];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K in %@",uniqueKey,existingAppUserUniqueIdentifiers];
                        NSArray *toRemove = [temp filteredArrayUsingPredicate:predicate];
                        
                        [temp removeObjectsInArray:toRemove];
                        
                        newUsers = [NSArray arrayWithArray:temp];
                        
                    }
                }
                else {
                    appUsersExist = NO;
                    newUsers = allUsers;
                }
                [self hideActivity];
                [self refreshSelectedUsers];
                [tableView reloadData];
            }
            else
            {
                [self hideActivity];
                [ABErrorManager handleError:error];
            }
            [self hideActivity];
            [tableView reloadData];
        }];
    }
    
}

#pragma mark - refresh Selctions

- (void)refreshSelectedUsers {
    
    if (selectedAppUsers.count>0) {
        
        NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"%K in %@",CHANNEL,[selectedAppUsers valueForKey:CHANNEL]];
        NSArray *users = [appUsers filteredArrayUsingPredicate:friendPredicate];
        
        if (users.count>0) {
            [selectedAppUsers removeAllObjects];
            [selectedAppUsers addObjectsFromArray:users];
        }
        
    }
}

#pragma mark - UI

- (void)setupUI {
    
    tableView.tableFooterView = [UIView new];
}

#pragma mark - View Controller life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.platform = PlatformPhoneBook;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appUsersExist = NO;
    selectedAppUsers = [NSMutableArray new];
    selectedNewUsers = [NSMutableArray new];
    
    filteredAppUsers = [NSMutableArray new];
    filteredNewUsers = [NSMutableArray new];
    
    [tableView registerNib:[UINib nibWithNibName:@"ABContactTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userCell"];
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"ABContactTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (appUsersExist && appUsers.count>0) {
        
        PFUser *currentUser = [PFUser currentUser];
        
        NSPredicate *friendPredicate = [NSPredicate predicateWithFormat:@"%K in %@",CHANNEL,currentUser[FACEBOOK_FRIENDS]];
        
        NSArray *friends = [appUsers filteredArrayUsingPredicate:friendPredicate];
        
        if (friends.count>0) {
            NSMutableArray *hold = [NSMutableArray arrayWithArray:appUsers];
            [hold removeObjectsInArray:friends];
            appUsers = [NSArray arrayWithArray:hold];
            [selectedAppUsers removeObjectsInArray:friends];
            if (appUsers.count==0) {
                appUsersExist = NO;
            }
            [tableView reloadData];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:FRIENDS_REQUESTS_REFRESHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:FRIENDS_REFRESHED object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FRIENDS_REQUESTS_REFRESHED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FRIENDS_REFRESHED object:nil];
}

#pragma mark - Actions

- (void)onNewUserAction:(UIButton*)_button {
    
    NSUInteger tag = _button.tag;
    
    NSDictionary *contactDict = newUsers[tag];
    
    
    if (![selectedNewUsers containsObject:contactDict]) {
        [selectedNewUsers addObject:contactDict];
        _button.selected = YES;
    }
    else {
        [selectedNewUsers removeObject:contactDict];
        _button.selected = NO;
    }
}

- (void)onAppUsersAction:(UIButton*)_button {
    
    NSUInteger tag = _button.tag;
    
    PFUser *user = appUsers[tag];
    
    if (![selectedAppUsers containsObject:user]) {
        [selectedAppUsers addObject:user];
        _button.selected = YES;
    }
    else {
        [selectedAppUsers removeObject:user];
        _button.selected = NO;
    }
    
}

- (void)onFilteredNewUserAction:(UIButton*)_button {
    
    NSUInteger tag = _button.tag;
    
    NSDictionary *contactDict = filteredNewUsers[tag];
    
    
    if (![selectedNewUsers containsObject:contactDict]) {
        [selectedNewUsers addObject:contactDict];
        _button.selected = YES;
    }
    else {
        [selectedNewUsers removeObject:contactDict];
        _button.selected = NO;
    }
}

- (void)onFilteredAppUsersAction:(UIButton*)_button {
    
    NSUInteger tag = _button.tag;
    
    PFUser *user = filteredAppUsers[tag];
    
    if (![selectedAppUsers containsObject:user]) {
        [selectedAppUsers addObject:user];
        _button.selected = YES;
    }
    else {
        [selectedAppUsers removeObject:user];
        _button.selected = NO;
    }
    
}

- (void)onNewUsersAddAllAction:(UIButton*)_button {

    [selectedNewUsers removeAllObjects];
    [selectedNewUsers addObjectsFromArray:newUsers];
    [tableView reloadData];
}

- (void)onAppUsersAddAllAction:(UIButton*)_button {
    [selectedAppUsers removeAllObjects];
    [selectedAppUsers addObjectsFromArray:appUsers];
    [tableView reloadData];
}

- (void)onNext:(id)sender {
    
    [self.view endEditing:YES];
    
    if (!appUsersExist) {
        if (selectedNewUsers.count==0) {
            [ABErrorManager showAlertWithMessage:@"Please select atleast one user."];
            return;
        }
    }
    else {
        NSUInteger count = selectedAppUsers.count+selectedNewUsers.count;
        if (count==0) {
            [ABErrorManager showAlertWithMessage:@"Please select atleast one user."];
            return;
        }
    }
    
    [self addFriendRequests];
}

- (void)onSkip:(id)sender {
    
    if (self.navigationMode==NavigationModeGoForward) {
        [[ABKlaus appDelegate] setRootController];
    }
    else {
        [self.parentViewController.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Friend Requests

- (void)sendFriendRequests {
    
    if (selectedAppUsers.count>0)
    {
        [self showActivity];
        
        [[ABUserManager sharedManager] requestToPeople:selectedAppUsers success:^(NSArray *result) {
            [self hideActivity];
            [self onSkip:nil];
        } failure:^(NSError *error) {
            [self hideActivity];
            [ABErrorManager handleError:error];
            [self onSkip:nil];
        }];
    }
    else
    {
        [self onSkip:nil];
    }

}

- (void)addFriendRequests {
    
    if (selectedNewUsers.count>0)
    {
        if (self.platform==PlatformPhoneBook)
        {
            
            if ([MFMessageComposeViewController canSendText]) {
                
                NSArray *recipents = [selectedNewUsers valueForKey:PHONE_NO];
                NSString *message = [NSString stringWithFormat:@"Hey checkout this amazing app ShoppingHook! http://www.shoppinghook.com/app"];
    
                MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                messageController.messageComposeDelegate = self;
                [messageController setRecipients:recipents];
                [messageController setBody:message];
                
                // Present message view controller on screen
                [[ABKlaus appDelegate].window.rootViewController presentViewController:messageController animated:YES completion:nil];
                
            }
            else {
                [self sendFriendRequests];
            }
            
        }
        else
        {
            // Send Facebook Notification
            NSArray *fbFriendIds = [selectedNewUsers valueForKey:FACEBOOK_ID];
            NSLog(@"%@",fbFriendIds);
            
            NSString *suggestedFriendsStr = [fbFriendIds componentsJoinedByString:@","];
            
            NSMutableDictionary* params =   [@{@"to":suggestedFriendsStr} mutableCopy];
            [params setObject: @"1" forKey:@"frictionless"];
            
            if (ms_friendCache == NULL) {
                ms_friendCache = [[FBFrictionlessRecipientCache alloc] init];
            }
            
            [ms_friendCache prefetchAndCacheForSession:nil];
            
            [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                          message:[NSString stringWithFormat:@"Hey checkout this amazing app!"]
                                                            title:@"ShoppingHook"
                                                       parameters:params
                                                          handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                              if (error)
                                                              {
                                                                  // Case A: Error launching the dialog or sending request.
                                                                  NSLog(@"Error sending request.");
                                                              }
                                                              else
                                                              {
                                                                  if (result == FBWebDialogResultDialogNotCompleted)
                                                                  {
                                                                      // Case B: User clicked the "x" icon
                                                                      NSLog(@"User canceled request.");
                                                                      [self sendFriendRequests];
                                                                  }
                                                                  else
                                                                  {
                                                                      NSLog(@"Request Sent.");
                                                                      
                                                                      if (![resultURL query])
                                                                      {
                                                                          return;
                                                                      }
                                                                      
                                                                      NSDictionary *params = [self parseURLParams:[resultURL query]];
                                                                      NSMutableArray *recipientIDs = [[NSMutableArray alloc] init];
                                                                      for (NSString *paramKey in params)
                                                                      {
                                                                          if ([paramKey hasPrefix:@"to["])
                                                                          {
                                                                              [recipientIDs addObject:[params objectForKey:paramKey]];
                                                                          }
                                                                      }
                                                                      if ([params objectForKey:@"request"])
                                                                      {
                                                                          NSLog(@"Request ID: %@", [params objectForKey:@"request"]);
                                                                      }
                                                                      if ([recipientIDs count] > 0)
                                                                      {
                                                                          NSLog(@"Invited friends");
                                                                          [self sendFriendRequests];
                                                                      }

                                                                      
                                                                  }
                                                              }
                                                              //[self sendFriendRequests];
                                                          }
                                                      friendCache:ms_friendCache];
            
        }
    }
    else
    {
        [self sendFriendRequests];
    }
}

#pragma mark - TableView Data Source & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    
    if (!appUsersExist) {
        return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    
    BOOL isSearchTable = (aTableView==self.searchDisplayController.searchResultsTableView)?YES:NO;
    
    if (isSearchTable) {
        if (!appUsersExist) {
            return filteredNewUsers.count;
        }
        else {
            if (section==0) {
                return filteredAppUsers.count;
            }
            else {
                return filteredNewUsers.count;
            }
        }
    }
    else{
        if (!appUsersExist) {
            return newUsers.count;
        }
        else {
            if (section==0) {
                return appUsers.count;
            }
            else {
                return newUsers.count;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section {
    
    BOOL isSearchTable = (aTableView==self.searchDisplayController.searchResultsTableView)?YES:NO;
    if (isSearchTable)
    {
        return 0.5;
    }else
    {
        return 60.0;
    }
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
    
    BOOL isSearchTable = (aTableView==self.searchDisplayController.searchResultsTableView)?YES:NO;
    
    if (isSearchTable) {
        return nil;
    }
    
    ABUserSectionHeaderView *headerView = [ABUserSectionHeaderView loadFromNib];
    
    if (!appUsersExist) {
        headerView.lblStatement.text = [NSString stringWithFormat:@"You've %lu contacts which are not currently on Shoppinghook",(unsigned long)newUsers.count];
        [headerView.btnAction addTarget:self action:@selector(onNewUsersAddAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        if (section==0) {
            headerView.lblStatement.text = [NSString stringWithFormat:@"You've %lu contacts which are already on Shoppinghook",(unsigned long)appUsers.count];
            [headerView.btnAction addTarget:self action:@selector(onAppUsersAddAllAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            headerView.lblStatement.text = [NSString stringWithFormat:@"You've %lu contacts which are not currently on Shoppinghook",(unsigned long)newUsers.count];
            [headerView.btnAction addTarget:self action:@selector(onNewUsersAddAllAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    BOOL isSearchTable = (aTableView==self.searchDisplayController.searchResultsTableView)?YES:NO;
    
    static NSString *cellIdentifier = @"userCell";
    
    ABContactTableViewCell *cell = (ABContactTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.btnAction.tag = indexPath.row;
    
    if (!appUsersExist) {
        
        NSDictionary *contactDict = newUsers[indexPath.row];
        
        if (isSearchTable) {
            contactDict = filteredNewUsers[indexPath.row];
            [cell.btnAction addTarget:self action:@selector(onFilteredNewUserAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            [cell.btnAction addTarget:self action:@selector(onNewUserAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.lblTitle.text = [NSString stringWithFormat:@"%@ %@",contactDict[FIRST_NAME],contactDict[LAST_NAME]];
        
        if ([selectedNewUsers containsObject:contactDict]) {
            cell.btnAction.selected = YES;
        }
        else {
            cell.btnAction.selected = NO;
        }
        
        return cell;
        
    }
    else {
        
        if (indexPath.section==0) {
            
            PFUser *user = appUsers[indexPath.row];
            
            if (isSearchTable) {
                user = filteredAppUsers[indexPath.row];
                [cell.btnAction addTarget:self action:@selector(onFilteredAppUsersAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            else {
               [cell.btnAction addTarget:self action:@selector(onAppUsersAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            cell.lblTitle.text = [NSString stringWithFormat:@"%@",user[FULL_NAME]];
            
            
            if ([selectedAppUsers containsObject:user]) {
                cell.btnAction.selected = YES;
            }
            else {
                cell.btnAction.selected = NO;
            }
            
            return cell;
            
        }
        else{
            
            NSDictionary *contactDict = newUsers[indexPath.row];
            
            if (isSearchTable) {
                contactDict = filteredNewUsers[indexPath.row];
                [cell.btnAction addTarget:self action:@selector(onFilteredNewUserAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [cell.btnAction addTarget:self action:@selector(onNewUserAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            cell.lblTitle.text = [NSString stringWithFormat:@"%@ %@",contactDict[FIRST_NAME],contactDict[LAST_NAME]];
            
            if ([selectedNewUsers containsObject:contactDict]) {
                cell.btnAction.selected = YES;
            }
            else {
                cell.btnAction.selected = NO;
            }
            
            return cell;
            
        }
        
    }
    
    return nil;

}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Search Display Controller Delegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    
    NSMutableSet *newUserResults = [NSMutableSet set];
    NSMutableSet *appUserResults = [NSMutableSet set];
    NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
    
    for (NSString *term in searchTerms) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"firstName BEGINSWITH[cd] %@ OR lastName BEGINSWITH[cd] %@ OR fullName BEGINSWITH[cd] %@",term,term,term];
        [newUserResults addObjectsFromArray:[newUsers filteredArrayUsingPredicate:resultPredicate]];
        [appUserResults addObjectsFromArray:[appUsers filteredArrayUsingPredicate:resultPredicate]];
    }
    
    [filteredAppUsers removeAllObjects];
    [filteredAppUsers addObjectsFromArray:[appUserResults allObjects]];
    
    [filteredNewUsers removeAllObjects];
    [filteredNewUsers addObjectsFromArray:[newUserResults allObjects]];
    
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

#pragma mark - Parse URL

- (NSDictionary *)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        
        [params setObject:[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                   forKey:[[kv objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return params;
}

#pragma mark - Message Delegate

#pragma mark - MessageDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            [ABErrorManager showAlertWithMessage:@"Failed to send SMS!"];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [[ABKlaus appDelegate].window.rootViewController dismissViewControllerAnimated:YES completion:^{
        [self sendFriendRequests];
    }];
}

@end
