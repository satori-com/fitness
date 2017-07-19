//
//  SessionConnector.h
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface SessionConnector : NSObject<WCSessionDelegate>

- (void)send:(NSDictionary<NSString *, id> *)message;

@end
