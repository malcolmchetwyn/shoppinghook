//
//  ReachabilityManager.h
//  Dwight
//
//  Created by R&D on 08/03/2014.

//

#import <Foundation/Foundation.h>
#import "Reachability.h"

#define kInternetStatusChanged  @"InternetStatusChanged"

@interface ABReachabilityManager : NSObject

{
    Reachability*   _internetReachability;
}

+(ABReachabilityManager *)sharedManager;

-(void)startMonitoring;
-(void)stopMonitoring;
-(BOOL)isInternetAvailable;

@end
