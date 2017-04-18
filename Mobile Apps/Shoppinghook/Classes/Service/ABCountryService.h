//
//  ABCountryService.h
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 02/04/2014.
//

#import <Foundation/Foundation.h>

@interface ABCountryService : NSObject {
    NSArray *countries;
}


- (NSArray*)listOfCountries;
- (NSDictionary*)countryForCountryCode:(NSString*)_code;
- (NSString*)dialingCodeForCountryCode:(NSString*)_code;
+ (ABCountryService*)service;

@end
