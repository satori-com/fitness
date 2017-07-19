//
//  SatoriConnectionManager.h
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SatoriRtmSdkWrapper/SatoriRtmSdkWrapper.h>

typedef void(^SubscriptionDataHandler)(NSDictionary *dataBody, NSDictionary *errorBody);

@interface SatoriConnectionManager : NSObject

@property (nonatomic, strong) SatoriRtmConnection *rtm;

+(instancetype)sharedManager;
- (rtm_status)connect;
- (void)disconnect;
- (rtm_status)publishJson:(NSString*)json toChannel:(NSString*)channel;
- (rtm_status)subscribeToChannel:(NSString*)channel withMessageHandler:(SubscriptionDataHandler)messageHandler;
- (rtm_status)subscribeWithBody:(NSDictionary*)body withMessageHandler:(SubscriptionDataHandler)messageHandler;
- (rtm_status)unsubscribe:(NSString*)subscriptionId;
@end
