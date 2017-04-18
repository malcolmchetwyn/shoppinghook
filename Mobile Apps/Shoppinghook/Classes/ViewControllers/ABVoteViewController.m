//
//  ABVoteViewController.m
//  Shoppinghook
//
//  Created on 21/04/2014.
//  
//

#import "ABVoteViewController.h"
#import "PieView.h"
#import "ABThumbnailView.h"
#import "ABPhotoBrowser.h"

#import "Activity.h"
#import "Picture.h"

@interface ABVoteViewController () <ABPhotoBrowserDelegate,ThumbnailSelectionDelegate>{
    
    NSDictionary *resultDict;
    
    __weak IBOutlet UIView *viewControl;
    __weak IBOutlet PieView *viewRatingMeter;
    __weak IBOutlet UIButton *btnLike;
    
    UIButton *btnFeed;
    
    ABPhotoBrowser *viewPhotoBowser;
    ABThumbnailView *viewThumbnail;
    
}

- (IBAction)onFeed:(id)sender;
- (IBAction)onLike:(id)sender;
@end

@implementation ABVoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)setupUI {
    
    CGRect fullScreenRect = [UIScreen mainScreen].bounds;
    
    viewPhotoBowser = [[NSBundle mainBundle] loadNibNamed:@"ABPhotoBrowser" owner:nil options:nil][0];
    viewPhotoBowser.frame = fullScreenRect;
    viewPhotoBowser.delegate = self;
    [self.view insertSubview:viewPhotoBowser belowSubview:viewControl];
    
    viewThumbnail = [[NSBundle mainBundle] loadNibNamed:@"ABThumbnailView" owner:nil options:nil][0];
    CGRect rect = viewThumbnail.frame;
    rect.origin.y = fullScreenRect.size.height - rect.size.height;
    viewThumbnail.frame = rect;
    
    viewThumbnail.delegate = self;
    
    [self.view insertSubview:viewThumbnail belowSubview:viewControl];
    
    btnFeed = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnFeed setFrame:CGRectMake(fullScreenRect.size.width-44 ,fullScreenRect.size.height-168, 44.0, 44.0)];
    [btnFeed setImage:[UIImage imageNamed:@"feed"] forState:UIControlStateNormal];
    [btnFeed addTarget:self action:@selector(onFeed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:btnFeed aboveSubview:viewControl];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpData];
    [viewRatingMeter setRating:0.0];
    [self getActivityResults];
    
    
    if (self.activity.vote || [self.activity.fromUserId isEqualToString:[PFUser currentUser][CHANNEL]]) {
        btnLike.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setRatingForIndex:0];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onFeed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)onLike:(id)sender {
    
    if (![self isConnected]) {
        return;
    }
    
    NSUInteger index = viewThumbnail.selectedIndex;
    
    NSString *selectedProperty = [NSString stringWithFormat:@"pic%lu",(unsigned long)index+1];
    
    NSString *pictureId = self.activity[selectedProperty];
    
    self.activity.vote = pictureId;
    self.activity.status = VOTE;
    
    [self.activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [[ABActivityResultManager sharedManager] refreshActivityResultsForActivityId:self.activity.activityId success:^(NSDictionary *result) {}];
        
        if (!error)
        {
        }
        else
        {
            [ABErrorManager handleError:error];
        }
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)setRatingForIndex:(NSUInteger)index {
    
    if (!resultDict) {
        return;
    }
    
    NSString *selectedProperty = [NSString stringWithFormat:@"pic%lu",(unsigned long)index+1];
    
    NSString *pictureId = self.activity[selectedProperty];
    
    NSNumber *vote = resultDict[pictureId];
    
    NSNumber *total = resultDict[@"voteCount"];
    
    CGFloat percentage = 0;
    
    if (total.integerValue>0) {
        percentage = 100.0 * (vote.floatValue/total.floatValue);
    }
    
    NSLog(@"INDEX ->%@ percentage -> %f",@(index),percentage);
    
    [viewRatingMeter setRating:percentage];
}

#pragma mark - Request

- (void) getActivityResults {
    
    [[ABActivityResultManager sharedManager] getActivityResultsForActivityId:self.activity.activityId success:^(NSDictionary *result) {
        resultDict = result;
        [viewThumbnail selectImageAtIndex:0];
    }];
    
}

- (void)setUpData {
    
    [viewThumbnail addPictureWithId:self.activity.pic1];
    [viewPhotoBowser addPictureWithId:self.activity.pic1];
    
    if (self.activity.pic2) {
        [viewThumbnail addPictureWithId:self.activity.pic2];
        [viewPhotoBowser addPictureWithId:self.activity.pic2];
    }
    
    if (self.activity.pic3) {
        [viewThumbnail addPictureWithId:self.activity.pic3];
        [viewPhotoBowser addPictureWithId:self.activity.pic3];
    }
    
    if (self.activity.pic4) {
        [viewThumbnail addPictureWithId:self.activity.pic4];
        [viewPhotoBowser addPictureWithId:self.activity.pic4];
    }
    
    [viewThumbnail selectImageAtIndex:0];
    
}

#pragma mark - ThumbnailSeletionDelegate

- (void)thumbnailSelectedAtIndex:(NSUInteger)selectedIndex {
    //[self setRatingForIndex:selectedIndex];
    [viewPhotoBowser showItemAtIndex:selectedIndex];
    
}

#pragma mark - PhotoBrowserDelegate
- (void)didScrolledToPage:(NSUInteger)page {
    [self setRatingForIndex:page];
    viewThumbnail.delegate = nil;
    [viewThumbnail selectImageAtIndex:page];
    viewThumbnail.delegate = self;
}

@end
