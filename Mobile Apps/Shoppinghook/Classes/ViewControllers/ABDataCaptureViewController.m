//
//  ABDataCaptureViewController.m
//  Shoppinghook
//
//  Created on 30/03/2014.
//  
//

#import "ABDataCaptureViewController.h"
#import "ABFriendListViewController.h"
#import "ABFeedViewController.h"
#import "EasyReviewCameraOverLay.h"
#import "M13BadgeView.h"

@interface ABDataCaptureViewController () <ImageCaptureDelegate,ActivityDelegate>{
    
    EasyReviewCameraOverLay *cameraViewer;
    
    IBOutlet UIView *badgeSuperView;
    IBOutlet M13BadgeView *badgeView;
}

@end

@implementation ABDataCaptureViewController

- (void)initBadgeView {
    
    badgeView = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [badgeView setText:@"0"];
    [badgeSuperView addSubview:badgeView];
    badgeView.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
    badgeView.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
    
    badgeSuperView.hidden = YES;
}

-(void) initCameraView {
    
#if TARGET_IPHONE_SIMULATOR
    return;
#endif
    
    cameraViewer = [[EasyReviewCameraOverLay alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [cameraViewer setParentVC:self];
    cameraViewer.delegate = self;
    [self.view addSubview:cameraViewer];
    
}

- (void)setupUI {
    [self initCameraView];
    [self initBadgeView];
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newActivityRequest:)
                                                 name:NEW_ACTIVITY_REQUEST_NOTIFICATION
                                               object:nil];
    
    [self newActivityRequest:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NEW_ACTIVITY_REQUEST_NOTIFICATION
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions 

- (void)newActivityRequest:(NSNotification*)_ntf {
    
    if ([[ABPushManager sharedManager] activityRequestCount]==0) {
        badgeSuperView.hidden = YES;
    }
    else {
        NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)[[ABPushManager sharedManager] activityRequestCount]];
        badgeView.text = count;
        badgeSuperView.hidden = NO;
        [self.view bringSubviewToFront:badgeSuperView];
    }
    
}

- (IBAction)post:(id)sender {
    
    UIImage *image = [UIImage imageNamed:@"emma"];
    UIImage *aImage = [UIImage imageNamed:@"jeni"];
    [self imagesCaptured:@[image,aImage]];
}

#pragma mark - Feed

- (IBAction)goToFeed {
    [self.navigationController pushViewController:[ABFeedViewController loadFromNib] animated:YES];
}

#pragma mark -ImageCaptureDelegate
- (void)imagesCaptured:(NSArray *)_images {
    ABFriendListViewController *listVC = [ABFriendListViewController new];
    listVC.delegate = self;
    listVC.images = _images;
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark - Activity Delegate

- (void)activitySaved {
    [cameraViewer clear];
}


@end
