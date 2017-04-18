//
//  ABCountryService.m
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 02/04/2014.
//

#import "ABCountryService.h"

@implementation ABCountryService


#pragma mark - Load Data

- (void)loadData {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    
    NSString *JSON = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *JSONData = [JSON dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *list = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:nil];
    
    countries = [[NSArray alloc] initWithArray:list];
}

#pragma mark - Methods

- (NSArray*)listOfCountries {
    return countries;
}

- (NSDictionary*)countryForCountryCode:(NSString*)_code {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",CODE,_code];
    NSArray *results = [countries filteredArrayUsingPredicate:predicate];
    
    NSDictionary *country = [results firstObject];
    if (country) {
        return country;
    }
    return [self countryForCountryCode:@"US"];
}

- (NSString*)dialingCodeForCountryCode:(NSString*)_code {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",CODE,_code];
    NSArray *results = [countries filteredArrayUsingPredicate:predicate];
    
    NSDictionary *country = [results firstObject];
    if (country) {
        return country[DIAL_CODE];
    }
    return nil;
}

#pragma mark - Sigelton

+ (ABCountryService *)service {
    static ABCountryService* sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance=[[ABCountryService alloc] init];
        [sharedInstance loadData];
    });
    return sharedInstance;
}

@end
