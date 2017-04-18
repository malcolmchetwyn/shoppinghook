//
//  ABKlaus.h
//  Dwight
//
//  Created by on 02/03/2014.

//

#import <Foundation/Foundation.h>


typedef enum {
    PlatformPhoneBook=0,
    PlatformFacebook
}Platform;

typedef enum {
    NavigationModeGoForward=0,
    NavigationModeGoBack
}NavigationMode;


// SuccessAnd Failure Response Blocks
typedef void (^SuccessBlock)(NSArray*);
typedef void (^ErrorBlock)(NSError*);

@class ABAppDelegate;

@interface ABKlaus : NSObject

+ (BOOL) isIPAD;
+ (BOOL) isIOS7AndHigher;
+ (ABAppDelegate*) appDelegate;
+ (BOOL)isValidEmail:(NSString*)_email;

+ (UIImage*)fixOrientation:(UIImage*)_image;

@end
