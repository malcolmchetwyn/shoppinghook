//
//  NSString+Additions.m
//  Dwight
//
//  Created by on 03/03/2014.

//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL)isEmpty {
    return ([self isEqualToString:@""] || !self.length);
}

- (NSString*)stringByEscapingNullValues{
    NSString *className = NSStringFromClass([self class]);
    if ([self isKindOfClass:[NSNull class]] ||
        [className isEqualToString:@"(null)"] ||
        [className isEqualToString:@"<null>"] ||
        [className isEqualToString:@"__NSArrayM"] ||
        self.length==0)
    {
        return @"";
    }else{
        return self;
    }
}

- (NSString*)stringByEscapingMultipleSpaces{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSString *trimmedString = [regex stringByReplacingMatchesInString:self
                                                              options:0
                                                                range:NSMakeRange(0, [self length])
                                                         withTemplate:@" "];
    return trimmedString;
}

@end
