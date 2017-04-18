

#import <UIKit/UIKit.h>
#import "UIView+PopAnimation.h"


@protocol NotificationDelegate <NSObject>

@optional
- (BOOL)notificationViewShouldDismissWithValue:(NSString*)_value;
- (void)notificationViewDidDismissed;
- (void)notificationViewDidDismissedWithValue:(NSString*)_value;
- (void)notificationViewDidDismissedWithValue:(BOOL)_selected
                                       andTag:(NSUInteger)_tag;

@end

@interface NotificationView : UIView <UITextViewDelegate>{
    __weak IBOutlet UIView *viewContainer;
    __weak IBOutlet UIButton *btnDismiss;
}

@property (weak) id<NotificationDelegate> delegate;

- (void)showNotificationWithDelegate:(id<NotificationDelegate>)aDlegate;
- (void)hideView;
- (IBAction)onDismiss:(id)sender;

+ (NotificationView*)notificationView;

@end
