//
//  Group.m
//  Shoppinghook
//
//  Created by Malcolm Fitzgerald on 31/03/2014.

//

#import "Group.h"

@implementation Group

- (id)init {
    self = [super init];
    
    if (self) {
        self.name = @" ";
        self.users = [NSMutableArray new];
    }
    
    return self;
}

@end
