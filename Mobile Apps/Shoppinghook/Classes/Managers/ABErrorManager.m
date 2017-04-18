//
//  ABErrorManager.m
//  Dwight
//
//  Created on 15/03/2014.

//

#import <Parse/Parse.h>
#import "ABErrorManager.h"
#import "UIAlertView+Blocks.h"

/*
 "password_length" = "Password must be atleast 6 character long";
 "signup_success" = "Share facts, interesting ideas and pro tips";
 "email_not_found" = "This email is not registered in our database";
 "email_not_already_taken" = "This email is already associated with another user";
 "wrong_credentials" = "Your email or password is not correct. Please try again.";
 "network_availability" = "Your network seems to be offline";
 "unknown_error" = "An unknown error has occured.";
 */


@implementation ABErrorManager

+ (void)showAlertWithMessage:(NSString*)_message {
    
    [UIAlertView showWithTitle:NSLocalizedString(@"message", nil)
                       message:_message
             cancelButtonTitle:NSLocalizedString(@"OK", nil)
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          
                          
                      }];
}

+ (void)handleError:(NSError*)_error {
    
    NSInteger code = [_error code];
    
    NSLog(@"Error occured with code (%ld) and description -> %@",(long)code,[_error userInfo][@"error"]);
    
    NSString *message = @"";
    
    if (code == kPFErrorObjectNotFound) {
        message = NSLocalizedString(@"The requested data doesn't exist", nil);
    }
    else if (code == kPFErrorConnectionFailed) {
        message = NSLocalizedString(@"network_availability", nil);
    }
    else if (code == kPFErrorInvalidEmailAddress) {
        message = NSLocalizedString(@"email_not_found", nil);
    }
    else if (code == kPFErrorInternalServer) {
        message = NSLocalizedString(@"unknown_error", nil);
    }
    else if (code == kPFErrorUsernameTaken) {
        message = NSLocalizedString(@"email_not_already_taken", nil);
    }
    else if (code == kPFErrorUserWithEmailNotFound) {
        message = NSLocalizedString(@"email_not_found", nil);
    }
    else {
        message = [_error userInfo][@"error"];
    }
    
    [ABErrorManager showAlertWithMessage:message];
    
}

@end
