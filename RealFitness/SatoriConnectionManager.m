//
//  SatoriConnectionManager.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "SatoriConnectionManager.h"
#import "Constants.h"

@interface SatoriConnectionManager ()
@property (nonatomic, strong) PduHandler pduHandler;
@property (nonatomic, strong) NSMutableDictionary *messageHandlerDict;
@end

@implementation SatoriConnectionManager

+(instancetype)sharedManager {
    static SatoriConnectionManager *sharedConnManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConnManager = [[self alloc] init];
    });
    return sharedConnManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.rtm = [[SatoriRtmConnection alloc] initWithUrl:Url andAppkey:AppKey];
        self.messageHandlerDict = [NSMutableDictionary new];

        __weak SatoriConnectionManager *weakSelf = self;
        self.pduHandler = ^(SatoriPdu *pdu){
            NSLog(@"pdu body %@", pdu.body);
            if (pdu != nil) {
                NSDictionary *subscriptionBody = nil;
                NSDictionary *subscriptionError = nil;
                
                if (pdu.action == RTM_ACTION_SUBSCRIPTION_DATA) {
                    subscriptionBody = pdu.body;
                }
                else if (pdu.action == RTM_ACTION_SUBSCRIPTION_ERROR) {
                    subscriptionError = pdu.body;
                }
                
                SubscriptionDataHandler handler = [weakSelf.messageHandlerDict objectForKey:[pdu.body objectForKey:Subscription_id]];
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(subscriptionBody, subscriptionError);
                    });
                }
            }
        };
    }
    return self;
}

- (rtm_status)connect {
    return [self.rtm connectWithPduHandler:self.pduHandler];
}

- (void)disconnect {
    [self.rtm disconnect];
}

-(rtm_status)publishJson:(NSString *)json toChannel:(NSString *)channel{
    //Set reqId with an unsigned int value to receive acknowledgement.
    unsigned int reqId = 123;
    rtm_status stat = [self.rtm publishJson:json toChannel:channel andRequestId:&reqId];
    if (stat != RTM_OK) {
        NSLog(@"Failed to send publish request");
        return stat;
    }
    stat = [self.rtm waitWithTimeout:10];
    return stat;
}

- (rtm_status)subscribeToChannel:(NSString *)channel withMessageHandler:(SubscriptionDataHandler)messageHandler {
    [self addMessageHandler:messageHandler withKey:channel];
    //Set reqId with an unsigned int value to receive acknowledgement.
    unsigned int reqId = 123;
    return [self.rtm subscribe:channel andRequestId:&reqId];
}

- (rtm_status)subscribeWithBody:(NSDictionary*)body withMessageHandler:(SubscriptionDataHandler)messageHandler {
    [self addMessageHandler:messageHandler withKey:[body objectForKey:Subscription_id]];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
    NSString *bodyStr;
    if (error) {
        NSLog(@"Error parsing body %@", error);
        return RTM_ERR_PARAM;
    } else {
        bodyStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    unsigned int reqId = 123;
    return [self.rtm subscribeWithBody:bodyStr andRequestId:&reqId];
}

- (rtm_status)unsubscribe:(NSString *)subscriptionId {
    [self removeMessageHandlerForKey:subscriptionId];
    //Set reqId with an unsigned int value to receive acknowledgement.
    unsigned int reqId = 123;
    return [self.rtm unsubscribe:subscriptionId andRequestId:&reqId];
}

- (void)addMessageHandler:(SubscriptionDataHandler)messageHandler withKey:(NSString *)key {
    if (messageHandler != nil) {
        [self.messageHandlerDict setObject:messageHandler forKey:key];
    }
}

- (void)removeMessageHandlerForKey:(NSString *)key {
    [self.messageHandlerDict removeObjectForKey:key];
}



@end
