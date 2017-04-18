//
//  ReachabilityManager.m
//  Poco
//
//  Created by coeus on 08/04/2013.

//

#import "ABReachabilityManager.h"

@interface ABReachabilityManager ()

-(void)networkStatusChanged:(NSNotification *)notification;

@end

@implementation ABReachabilityManager

#pragma mark - Class methods

+(ABReachabilityManager *)sharedManager
{
    static ABReachabilityManager* sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance=[[ABReachabilityManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Instance methods

-(id)init
{
    self=[super init];
    if (self) {
        
        _internetReachability=[Reachability reachabilityForInternetConnection];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkStatusChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
    }
    return self;
}

-(void)startMonitoring
{
    [_internetReachability startNotifier];
}

-(void)stopMonitoring
{
    [_internetReachability stopNotifier];
}

-(BOOL)isInternetAvailable
{
    BOOL isReachable=[_internetReachability connected];
    return isReachable;
}

#pragma mark Private

-(void)networkStatusChanged:(NSNotification *)notification
{
    NetworkStatus internetStatus=[_internetReachability currentReachabilityStatus];
    
	switch (internetStatus){
            
		case NotReachable:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInternetStatusChanged
                                                                object:[NSNumber numberWithBool:NO]];
            break;
		}
		case ReachableViaWiFi:
        case ReachableViaWWAN:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInternetStatusChanged object:[NSNumber numberWithBool:YES]];
			break;
		}
	}
}

@end
