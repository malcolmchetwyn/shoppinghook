//
//  ABErrorManager.h
//  Dwight
//
//  Created on 15/03/2014.

//

#import <Foundation/Foundation.h>

@interface ABErrorManager : NSObject

+ (void)showAlertWithMessage:(NSString*)_message;
+ (void)handleError:(NSError*)_error;

@end
