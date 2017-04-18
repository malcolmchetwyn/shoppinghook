//
//  NotificationView.m
//  FlowerApp
//
//  Created on 03/04/2014.
//
//

#import "NotificationView.h"
#import "ABAppDelegate.h"

@implementation NotificationView

- (void)setAppearance {
    
}

+ (NotificationView*)notificationView {
    
    NotificationView *view = nil;
    view = (NotificationView*)[[NSBundle mainBundle] loadNibNamed:@"NotificationView" owner:nil options:nil][0];
    [view setAppearance];
    view.hidden = YES;
    return view;
}

#pragma mark - Show

- (void)showView
{
    self.frame = CGRectMake(0, 0, 320, 568);
    
    ABAppDelegate *appDelegate = (ABAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window addSubview:self];
    
    [self showWithCompletionBlock:^{
        
    }];
}

- (void)showNotificationWithDelegate:(id<NotificationDelegate>)aDlegate
{
    self.delegate = aDlegate;
    [self showView];
    
}

#pragma mark - Hide

- (void)hideView {
    
}

#pragma mark - Actions

- (IBAction)onDismiss:(id)sender {
        [self hideWithCompletionBlock:^{
            [self removeFromSuperview];
        }];
}

@end
