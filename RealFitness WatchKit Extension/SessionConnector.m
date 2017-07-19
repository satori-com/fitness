//
//  SessionConnector.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "SessionConnector.h"

@interface SessionConnector ()
@property (nonatomic, strong) WCSession *session;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, id> *> *messages;
@end

@implementation SessionConnector

- (instancetype)init {
    self = [super init];
    if (self) {
        self.messages = [NSMutableArray<NSDictionary<NSString *, id> *> new];
        [WCSession defaultSession].delegate = self;
        if ([WCSession defaultSession].activationState == WCSessionActivationStateActivated) {
            self.session = [WCSession defaultSession];
        }
        else {
            [[WCSession defaultSession] activateSession];
        }
    }
    return self;
}

- (void)send:(NSDictionary<NSString *, id> *)message {
    if (self.session != nil) {
        if ([self.session isReachable]) {
            [self.session sendMessage:message replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
                NSLog(@"Error sending message: %@", error);
            }];
        }
    } else {
        [self.messages addObject:message];
    }
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    if (activationState == WCSessionActivationStateActivated) {
        self.session = session;
        [self sendPendingMessages];
    }
}

- (void)sendPendingMessages {
    if (self.session != nil) {
        if ([self.session isReachable]) {
            for (NSDictionary<NSString *, id> *message in self.messages) {
                [self.session sendMessage:message replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
                    NSLog(@"Error sending message: %@", error);
                }];
            }
            [self.messages removeAllObjects];
        }
    }
}


@end
