//
//  Picture.h
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 31/03/2014.
//

#import <Parse/Parse.h>

@interface Picture : PFObject <PFSubclassing>

@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSString *user;

@end
