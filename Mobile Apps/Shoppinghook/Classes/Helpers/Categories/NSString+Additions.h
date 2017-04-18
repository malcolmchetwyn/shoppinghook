//
//  NSString+Additions.h
//  Dwight
//
//  Created by on 03/03/2014.

//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (BOOL)isEmpty;
- (NSString*)stringByEscapingNullValues;
- (NSString*)stringByEscapingMultipleSpaces;

@end
