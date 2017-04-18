//
//  ABCountryViewController.h
//  Shoppinghook
//
//  Created on 02/04/2014.
//  
//

#import <UIKit/UIKit.h>

@protocol  CountrySelectionProtocol <NSObject>

@optional
- (void)didSelectedTheCountry:(NSDictionary*)_country;
@end

@interface ABCountryViewController : UITableViewController

@property (weak) id<CountrySelectionProtocol> delegate;

@end
