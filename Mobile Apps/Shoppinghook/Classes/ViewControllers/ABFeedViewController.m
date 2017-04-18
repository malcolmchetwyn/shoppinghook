//
//  ABFeedViewController.m
//  Shoppinghook
//
//  Created on 10/04/2014.
//  
//

#import "ABFeedViewController.h"
#import "ABSettingsViewController.h"
#import "ABVoteViewController.h"
#import "ABFriendCollectionViewController.h"

#import "ABActivityCell.h"
#import "BBBadgeBarButtonItem.h"
#import "M13BadgeView.h"

#import "Activity.h"
#import "Picture.h"

#define MAX_FEED_LIMIT 600

@interface ABFeedViewController () <UITableViewDataSource,UITableViewDelegate>{
    
    NSMutableArray *activities;
    //NSDictionary *activityDict;
    NSMutableArray *mutualActivities;
    __weak IBOutlet UITableView *tableView;
    
    __weak IBOutlet UIView *badgeSuperView;
    M13BadgeView *badgeView;
    
    __weak IBOutlet UIToolbar *toolbar;
    
    BBBadgeBarButtonItem *friendItem;
    BBBadgeBarButtonItem *refreshItem;
    
    //NSTimer *_timer;
    
}

@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (nonatomic,strong) NSTimer *timer;

- (IBAction)onSettings:(id)sender;
- (IBAction)onCamera:(id)sender;
- (IBAction)goToFriends:(id)sender;

@end

@implementation ABFeedViewController

#pragma mark - VC Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Feed";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    tableView.tableFooterView = [UIView new];
    
    [tableView registerNib:[UINib nibWithNibName:@"ABActivityCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"activity"];
    
    [self getMutualActivities];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newActivityRequest:)
                                                 name:NEW_ACTIVITY_REQUEST_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newFriendRequest:)
                                                 name:NEW_FRIEND_REQUEST_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMutualActivities)
                                                 name:ACTIVITIES_REFRESHED
                                               object:nil];
    
    [self newFriendRequest:nil];
    
    //[tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self performSelectorOnMainThread:@selector(stopTimer) withObject:nil waitUntilDone:YES];
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NEW_ACTIVITY_REQUEST_NOTIFICATION
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NEW_FRIEND_REQUEST_NOTIFICATION
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ACTIVITIES_REFRESHED
                                                  object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - UI

- (void)setupToolbar {
    
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    refresh.frame = CGRectMake(0, 0, 30, 30);
    [refresh setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [refresh addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *camera = [UIButton buttonWithType:UIButtonTypeCustom];
    camera.frame = CGRectMake(0, 0, 30, 30);
    [camera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [camera addTarget:self action:@selector(onCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *friend = [UIButton buttonWithType:UIButtonTypeCustom];
    friend.frame = CGRectMake(0, 0, 30, 30);
    [friend setImage:[UIImage imageNamed:@"friends"] forState:UIControlStateNormal];
    [friend addTarget:self action:@selector(goToFriends:) forControlEvents:UIControlEventTouchUpInside];
    
    refreshItem = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:refresh];
    refreshItem.badgeBGColor = [UIColor redColor];
    refreshItem.badgeTextColor = [UIColor whiteColor];
    refreshItem.shouldHideBadgeAtZero = YES;
    refreshItem.badgeValue = @"1";
    refreshItem.badgeOriginX = 13;
    refreshItem.badgeOriginY = -9;
    
    UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc] initWithCustomView:camera];
    
    friendItem = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:friend];
    friendItem.badgeBGColor = [UIColor redColor];
    friendItem.badgeTextColor = [UIColor whiteColor];
    friendItem.shouldHideBadgeAtZero = YES;
    friendItem.badgeValue = @"1";
    friendItem.badgeOriginX = 13;
    friendItem.badgeOriginY = -9;
    
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    NSArray *items = @[refreshItem,spacer1,cameraItem,spacer2,friendItem];
    
    [toolbar setItems:items];
}

- (void)setupUI {
    
//    UIScreenEdgePanGestureRecognizer *recognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(goToFriends:)];
//    recognizer.edges = UIRectEdgeLeft;
//    [self.view addGestureRecognizer:recognizer];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:self.refreshControl];
    
    UIButton *settings = [UIButton buttonWithType:UIButtonTypeCustom];
    settings.frame = CGRectMake(0, 0, 30, 30);
    [settings setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [settings addTarget:self action:@selector(onSettings:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithCustomView:settings];
    
    self.navigationItem.leftBarButtonItem = settingsItem;
    
    
    [self setupToolbar];
    
    
}

#pragma mark - Start Timer

- (void)startTimer {

    [self.timer invalidate];
    self.timer = nil;
    
    NSTimer *newTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(timerFired:)
                                            userInfo:nil
                                             repeats:YES];
    self.timer = newTimer;
    [self.timer fire];

}

#pragma mark - Stop Timer

- (void)stopTimer {

    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Timer Action

- (void)timerFired:(NSTimer*)aTimer {
    
    NSArray *cells = [tableView visibleCells];
    
    if (!mutualActivities || mutualActivities.count==0) {
        return;
    }
    
    for (ABActivityCell *cell in cells) {
        
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        
        if (indexPath.row < mutualActivities.count) {
            
            Activity *activity = mutualActivities[indexPath.row];
            
            NSDate *now = [NSDate date];
            NSDate *postDate = activity.createdAt;
            NSInteger seconds = (NSInteger)[now timeIntervalSinceDate:postDate];
            if (seconds>MAX_FEED_LIMIT) {
                [cell.lblTime setText:@"expired"];
                cell.backgroundColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:0.5];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            else {
                NSInteger min = seconds / 60;
                NSInteger sec = seconds - (min*60);
                [cell.lblTime setText:[NSString stringWithFormat:@"%ld:%02ld min ago",(long)min,(long)sec]];
                cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                
                [self getActivityResultsForActivityId:activity.activityId
                                          atIndexPath:indexPath];
                
            }
            
//            [self getActivityResultsForActivityId:activity.activityId
//                                      atIndexPath:indexPath];
        }
        
    }
    
}

#pragma mark - Notifications

- (void)newActivityRequest:(NSNotification*)_ntf {
    
    NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)[[ABPushManager sharedManager] activityRequestCount]];
    refreshItem.badgeValue = count;
}

- (void)newFriendRequest:(NSNotification*)_ntf {
    
    NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)[[ABPushManager sharedManager] friendRequestCount]];
    friendItem.badgeValue = count;
}

#pragma mark - Requests

- (void)reload:(id)sender {
    
    if (![[ABReachabilityManager sharedManager] isInternetAvailable]) {
        NSError *err = [NSError errorWithDomain:@"Shoppinghook" code:100 userInfo:@{}];
        [ABErrorManager handleError:err];
        return;
    }
    
    [self stopTimer];
    [[ABPushManager sharedManager] resetActivityRequestCount];
    
    [self newActivityRequest:nil];
    
    mutualActivities = nil;
    
    [self showActivity];
    
    [[ABActivityCache sharedCache] refreshActivitiesWithSuccess:^(NSArray *results) {
        
        mutualActivities = [NSMutableArray arrayWithArray:results];
        
        [self hideActivity];
        [self.refreshControl endRefreshing];
        [self startTimer];
        [tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideActivity];
        [self.refreshControl endRefreshing];
        [self startTimer];
        [tableView reloadData];
        
    }];
}

- (void)getMutualActivities {
    
    [self stopTimer];
    
    [[ABPushManager sharedManager] resetActivityRequestCount];
    [self newActivityRequest:nil];
    mutualActivities = nil;
    
    [[ABActivityCache sharedCache] getActivitiesWithSuccess:^(NSArray *results) {
        
        mutualActivities = [NSMutableArray arrayWithArray:results];
        
        [self.refreshControl endRefreshing];
        [self startTimer];
        [tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self.refreshControl endRefreshing];
        [self startTimer];
        [tableView reloadData];
        
    }];
    
}

- (void)deleteActivity:(Activity*)_activity {
    
    [[ABActivityCache sharedCache] deleteActivity:_activity];
}

#pragma mark - Activity Results

- (void)setUpResultForActivityId:(NSString*)_activityId
                          result:(NSDictionary*)_result
                     atIndexPath:(NSIndexPath*)_indexPath {
    
    Activity *activity = mutualActivities[_indexPath.row];
    
    if ([activity.activityId isEqualToString:_activityId]) {
        
        ABActivityCell *activityCell = (ABActivityCell*)[tableView cellForRowAtIndexPath:_indexPath];
        
        if (!activityCell) {
            return;
        }
        
        // Find Max
        
        NSString *winner = nil;
        BOOL goldenWinner = NO;
        
        NSNumber *max = _result[activity.pic1];
        winner = activity.pic1;
        
        if (activity.pic2) {
            NSNumber *count = _result[activity.pic2];
            
            if (count.integerValue>max.integerValue) {
                max = count;
                winner = activity.pic2;
            }
        }
        
        if (activity.pic3) {
            NSNumber *count = _result[activity.pic3];
            
            if (count.integerValue>max.integerValue) {
                max = count;
                winner = activity.pic3;
            }
        }
        
        if (activity.pic4) {
            NSNumber *count = _result[activity.pic4];
            
            if (count.integerValue>max.integerValue) {
                max = count;
                winner = activity.pic4;
            }
        }
        
        NSNumber *total = _result[@"voteCount"];
        
        if (max.integerValue==total.integerValue && max.integerValue>0) {
            goldenWinner = YES;
        }
        
        if (!goldenWinner) {
            activityCell.imgViewSingleWinner.hidden = YES;
        }
        else {
            activityCell.imgViewSingleWinner.hidden = NO;
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"Picture"];
        [query whereKey:OBJECT_ID equalTo:winner];
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            Picture *pic = (Picture*)object;
            activityCell.imgViewWinner.file = pic.image;
            [activityCell.imgViewWinner loadInBackground];
        }];
        
        
        
        NSNumber *vote = max;
        
        CGFloat percentage = 0;
        
        if (total.integerValue>0) {
            percentage = 100.0 * (vote.floatValue/total.floatValue);
        }
        
        [activityCell.viewRating setRating:percentage];
        
    }
    
}

- (void)getActivityResultsForActivityId:(NSString*)_activityId
                            atIndexPath:(NSIndexPath*)_indexPath {
    
    [[ABActivityResultManager sharedManager] getActivityResultsForActivityId:_activityId
                                                                     success:^(NSDictionary *result) {
                                                                         
                                                                         [self setUpResultForActivityId:_activityId
                                                                                                 result:result
                                                                                            atIndexPath:_indexPath];
        
                                                                    }];
    
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return mutualActivities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"activity";
    ABActivityCell *cell = (ABActivityCell*)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.imgViewSingleWinner.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Activity *activity = mutualActivities[indexPath.row];
    [self getActivityResultsForActivityId:activity.activityId
                              atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ABActivityCell *activityCell = (ABActivityCell*)cell;
    Activity *activity = mutualActivities[indexPath.row];
    
    NSDate *now = [NSDate date];
    NSDate *postDate = activity.createdAt;
    NSInteger seconds = (NSInteger)[now timeIntervalSinceDate:postDate];
    
    if (seconds>MAX_FEED_LIMIT) {
        [activityCell.lblTime setText:@"expired"];
        cell.backgroundColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:0.5];
    }
    else {
        NSInteger min = seconds / 60;
        NSInteger sec = seconds - (min*60);
        [activityCell.lblTime setText:[NSString stringWithFormat:@"%ld:%02ld min ago",(long)min,(long)sec]];
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
    
    if ([activity.fromUserId isEqualToString:[PFUser currentUser][CHANNEL]]) {
        activityCell.viewOwner.backgroundColor = [UIColor flatGreenSeaColor];
    }
    else {
        activityCell.viewOwner.backgroundColor = [UIColor flatSilverColor];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        
        [tableView beginUpdates];
        
        Activity *activity = mutualActivities[indexPath.row];
        [self deleteActivity:activity];
        [mutualActivities removeObject:activity];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [tableView endUpdates];
    }
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Activity *activity = mutualActivities[indexPath.row];
    
    NSDate *now = [NSDate date];
    NSDate *postDate = activity.timestamp;
    NSInteger seconds = (NSInteger)[now timeIntervalSinceDate:postDate];
    
    if (seconds<=MAX_FEED_LIMIT) {
        ABVoteViewController *voteCtr = [ABVoteViewController loadFromNib];
        voteCtr.activity = activity;
        [self.navigationController pushViewController:voteCtr animated:YES];
    }
}


#pragma mark - Actions

- (IBAction)onSettings:(id)sender {
    
    [self.navigationController pushViewController:[ABSettingsViewController loadFromNib] animated:YES];
}

- (IBAction)onCamera:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)goToFriends:(id)sender {
    
    if ([sender isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        UIScreenEdgePanGestureRecognizer *recognizer = sender;
        if (recognizer.state!=UIGestureRecognizerStateEnded) {
            return;
        }
    }
    
    
    PFUser *currentUser = [PFUser currentUser];
    
    ABFriendCollectionViewController *friendVC = [ABFriendCollectionViewController loadFromNib];
    
    if (currentUser[FACEBOOK_ID]) {
        friendVC.platform = PlatformFacebook;
    }
    else {
        friendVC.platform = PlatformPhoneBook;
    }
    
    friendVC.navigationMode = NavigationModeGoBack;
    
    if ([[ABPushManager sharedManager] friendRequestCount]==0) {
        friendVC.showsFriendRequest = NO;
    }
    else {
        friendVC.showsFriendRequest = YES;
    }
    
    [self.navigationController pushViewController:friendVC animated:YES];
}

@end
