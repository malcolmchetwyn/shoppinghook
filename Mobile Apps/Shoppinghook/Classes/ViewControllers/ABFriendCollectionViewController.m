//
//  ABFViewController.m
//  SEGMENT
//
//  Created on 22/04/2014.
//  Copyright (c) 2014 Coeus Solutions GmbH. All rights reserved.
//

#import "ABFriendCollectionViewController.h"
#import "ABFriendFinderViewController.h"
#import "ABFriendRequestViewController.h"

#import "HMSegmentedControl.h"

@interface ABFriendCollectionViewController () {
    
    NSArray *viewControllers;
    
    ABFriendFinderViewController    *friendFinderFromPlatformViewController;
    ABFriendFinderViewController    *friendFinderFromContactsViewController;
    ABFriendRequestViewController   *friendRequestViewController;
    ABBaseViewController            *currentController;
    
    HMSegmentedControl *segmentedControl;
    
    __weak IBOutlet UIView *contentView;
}

@end

@implementation ABFriendCollectionViewController

- (BOOL)isViewControllerAtTop:(ABBaseViewController*)_viewController {
    
    if (_viewController==currentController)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Friend Requests";
    }
    return self;
}

- (void)addChildViewController:(UIViewController *)childController {
    
    childController.view.frame = contentView.frame;
    [self.view addSubview:childController.view];
    
    [childController willMoveToParentViewController:self];
    [super addChildViewController:childController];
    [childController didMoveToParentViewController:self];
    
}

- (void)addSegmentedControl {
    
    segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    NSArray *sectionTitles;
    CGFloat fontSize = 0.0;
    
    if (self.platform==PlatformFacebook) {
        sectionTitles = @[@"Facebook Friends",@"Contacts", @"Friend Requests"];
        fontSize = 12.0;
    }
    else {
        sectionTitles = @[@"Contacts", @"Friend Requests"];
        fontSize = 14.0;
    }
    
    segmentedControl.font = [UIFont fontWithName:@"Arial" size:fontSize];
    
    segmentedControl.sectionTitles = sectionTitles;
    segmentedControl.selectedSegmentIndex = 0;
    
    segmentedControl.backgroundColor = [[UIColor flatWetAsphaltColor] colorWithAlphaComponent:0.5];
    segmentedControl.selectionIndicatorColor = [[UIColor flatMidnightBlueColor] colorWithAlphaComponent:1.0];
    
    segmentedControl.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    segmentedControl.selectedTextColor = [UIColor whiteColor];
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:segmentedControl];
}

- (void)initializeBarItems {
    
    self.rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                         style:UIBarButtonItemStylePlain
                                                        target:nil
                                                        action:nil];
    
    if (self.navigationMode==NavigationModeGoForward) {
        
        self.leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Skip"
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:nil];
    }
}

- (void)setupUI {
    
    friendFinderFromPlatformViewController = [ABFriendFinderViewController loadFromNib];
    friendFinderFromPlatformViewController.platform = self.platform;
    friendFinderFromPlatformViewController.navigationMode = self.navigationMode;
    
    if (self.platform == PlatformFacebook) {
        friendFinderFromContactsViewController = [ABFriendFinderViewController loadFromNib];
        friendFinderFromContactsViewController.platform = PlatformPhoneBook;
        friendFinderFromContactsViewController.navigationMode = self.navigationMode;
    }
    
    friendRequestViewController = [ABFriendRequestViewController loadFromNib];
    
    
    if (self.platform == PlatformFacebook) {
        
        viewControllers = @[friendFinderFromPlatformViewController,
                            friendFinderFromContactsViewController,
                            friendRequestViewController];
    }
    else {
        viewControllers = @[friendFinderFromPlatformViewController,
                            friendRequestViewController];
    }
    
    [self addChildViewController:friendRequestViewController];
    
    if (self.platform == PlatformFacebook) {
        [self addChildViewController:friendFinderFromContactsViewController];
    }
    
    [self addChildViewController:friendFinderFromPlatformViewController];
    
    currentController = friendFinderFromPlatformViewController;
    
    [self addSegmentedControl];
    
    [self initializeBarItems];
    
    if (self.showsFriendRequest) {
        segmentedControl.selectedSegmentIndex =viewControllers.count-1;
        currentController = friendRequestViewController;
        [self.view bringSubviewToFront:currentController.view];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setBarItems];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reload];
}

- (void)reload {
    
    [friendFinderFromPlatformViewController getContacts];
    
    if (self.platform == PlatformFacebook) {
        [friendFinderFromContactsViewController getContacts];
    }
}

- (void)setBarItems
{
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem  = nil;
    
    if (currentController==friendRequestViewController)
    {
        
        self.title = @"Friend Requests";

        
        if (self.navigationMode==NavigationModeGoForward)
        {
            self.navigationItem.leftBarButtonItem = self.leftBarItem;
            self.leftBarItem.target = friendRequestViewController;
            self.leftBarItem.action = @selector(onSkip:);
        }
    }
    else
    {
        
        self.title = @"Find Friends";
        
        self.navigationItem.rightBarButtonItem = self.rightBarItem;
        self.rightBarItem.target = currentController;
        self.rightBarItem.action = @selector(onNext:);
        
        if (self.navigationMode==NavigationModeGoForward)
        {
            
            self.navigationItem.leftBarButtonItem = self.leftBarItem;
            self.leftBarItem.target = currentController;
            self.leftBarItem.action = @selector(onSkip:);
        }
    }
}

- (void)segmentedControlChangedValue:(id)sender
{
    ABBaseViewController *toController = viewControllers[segmentedControl.selectedSegmentIndex];
    
    if (toController==currentController) {
        return;
    }
    
    ABBaseViewController *fromController = currentController;
    
    [self transitionFromViewController:fromController
                      toViewController:toController
                              duration:0.10
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                
                            }
                            completion:^(BOOL finished) {
                                currentController = toController;
                                
                                [self setBarItems];
                            }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
