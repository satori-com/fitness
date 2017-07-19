//
//  ViewController.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "MyActivityViewController.h"
#import <SatoriRtmSdkWrapper/SatoriRtmSdkWrapper.h>
#import "Constants.h"
#import "SatoriConnectionManager.h"
#import <FLAnimatedImage/FLAnimatedImage.h>
#import "RealFitness-Swift.h"

@interface MyActivityViewController () {
    dispatch_queue_t _messageQueue;
    dispatch_queue_t _reactionQueue;
}
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) wcSessionActivationCompletion sessionActivationCompletion;
@property (nonatomic, strong) SatoriConnectionManager *connManager;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSMutableDictionary *messages;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, strong) NSString *lastTargetState;
@property (nonatomic, strong) NSString *currentTargetState;
@property (nonatomic, strong) NSString *lastWorkoutGoal;
@property (nonatomic, strong) SubscriptionDataHandler messageHandler;
@property (nonatomic, strong) FNReactionsView *reactionsView;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation MyActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.healthStore = [HKHealthStore new];
    _messageQueue = dispatch_queue_create("messagequeue", DISPATCH_QUEUE_SERIAL);
    _reactionQueue = dispatch_queue_create("reactionqueue", DISPATCH_QUEUE_CONCURRENT);
    self.connManager = [SatoriConnectionManager sharedManager];
    
    __weak MyActivityViewController *weakSelf = self;
    
    // Message handler for reactions
    self.messageHandler = ^(NSDictionary *body, NSDictionary *error) {
        if (body) {
            NSDictionary* msg = [[body objectForKey:@"messages"] objectAtIndex:0];
            if ([msg objectForKey:@"reaction"] != nil) {
                NSString *reaction = [msg objectForKey:@"reaction"];
                [weakSelf showReactionForImage:[[Constants reactionImages] objectForKey:reaction]];
            }
        }
    };
    
    // Connect
    dispatch_async(_messageQueue, ^{
        rtm_status status = [self.connManager connect];
        if (status != RTM_OK) {
            NSLog(@"Connection error");
            self.isConnected = NO;
        } else {
            self.isConnected = YES;
        }
    });
    
    self.messages = [NSMutableDictionary new];
    self.lastTargetState = @"";
    self.currentTargetState = @"";
    self.lastWorkoutGoal = @"";
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
    self.userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    if (self.userName != nil && self.userId != nil) {
        [self.messages setObject:self.userName forKey:@"username"];
        [self.messages setObject:self.userId forKey:@"userid"];
    }
    
    [self setLabelColors:[UIColor whiteColor]];
    [self setupReactionsView];
    
    // Reaction channel subscription and data handling
    dispatch_async(_reactionQueue, ^{
        SatoriRtmConnection *conn = [[SatoriRtmConnection alloc] initWithUrl:Url andAppkey:AppKey];
        PduHandler pduHandler = ^(SatoriPdu *pdu){
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
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.messageHandler(subscriptionBody, subscriptionError);
                });
                
            }
        };
        
        rtm_status stat = [conn connectWithPduHandler:pduHandler];
        if (stat != RTM_OK) {
            NSLog(@"Error in raw connection");
        }
        else {
            //Set reqId with an unsigned int value to receive acknowledgement.
            unsigned int reqId = 123;
            int i = 0;
            rtm_status stat = [conn subscribe:[NSString stringWithFormat:@"%@-%@", self.userId, @"Reactions"] andRequestId:&reqId];
            if (stat != RTM_OK) {
                NSLog(@"Error subscribing to %@-Reactions", self.userId);
            }
            while ([conn poll] >= 0) {
                if (i == 5) {
                    [conn publishJson:@"{\"keepalive\" : true}" toChannel:[NSString stringWithFormat:@"%@-%@", self.userId, @"Reactions"] andRequestId:&reqId];
                    i = 0;
                }
                i++;
                sleep(1);
            }
        }
    });
}

- (void)setupReactionsView {
    self.reactionsView = [FNReactionsView new];
    self.reactionsView.translatesAutoresizingMaskIntoConstraints = NO;
    self.reactionsView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.reactionsView];
    [self.reactionsView addConstraint:[NSLayoutConstraint constraintWithItem:self.reactionsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:300]];
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.reactionsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.reactionsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0],
                                ]];
}

-(void)showReactionForImage:(UIImage*)image {
    NSArray *reactions = @[image];
    for (int i=0; i < 10; i++) {
        UInt32 x = (UInt32)reactions.count;
        int a = arc4random_uniform(x);
        UIImage *img = [reactions objectAtIndex:a];
        [self.reactionsView showReactionWithImage:img];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.goalContainerView.layer.cornerRadius = 6.0;
    self.goalContainerView.layer.borderWidth = 1.0;
    self.goalContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self startWatchApp];
}

- (void)startWatchApp {
    HKWorkoutConfiguration *workoutConfiguration = [[HKWorkoutConfiguration alloc] init];
    workoutConfiguration.activityType = HKWorkoutActivityTypeRunning;
    workoutConfiguration.locationType = HKWorkoutSessionLocationTypeOutdoor;
    [self activateWCSession:^(WCSession *wcSession) {
        if ((wcSession.activationState == WCSessionActivationStateActivated) && (wcSession.isWatchAppInstalled)) {
            [self.healthStore startWatchAppWithWorkoutConfiguration:workoutConfiguration completion:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@",error);
                }
            }];
        }
    }];
}

-(void)activateWCSession:(wcSessionActivationCompletion)completion {
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        
        if (session.activationState == WCSessionActivationStateActivated) {
            completion(session);
        }
        else {
            [session activateSession];
            _sessionActivationCompletion = completion;
        }
    }
}

-(void)setLabelColors:(UIColor*)color {
    [self.distanceLabel setTextColor:color];
    [self.caloriesLabel setTextColor:color];
    [self.heartrateLabel setTextColor:color];
    [self.durationLabel setTextColor:color];
}

- (void)showRunningAnimation {
    if (self.workoutGoal.text != nil && [self.workoutGoal.text length] != 0) {
        if (([self.lastTargetState isEqualToString:self.currentTargetState] == NO) || ([self.lastWorkoutGoal isEqualToString:self.workoutGoal.text] == NO)) {
            self.lastTargetState = self.currentTargetState;
            self.lastWorkoutGoal = self.workoutGoal.text;
            NSString *gifName = [NSString stringWithFormat:@"%@_%@", [Constants getAnimationImagePrefixForState:self.currentTargetState], [[Constants workoutGoalImagePrefix] objectForKey:self.workoutGoal.text]];
            NSURL *url1 = [[NSBundle mainBundle] URLForResource:gifName withExtension:@"gif"];
            NSData *data1 = [NSData dataWithContentsOfURL:url1];
            FLAnimatedImage *animatedImage1 = [FLAnimatedImage animatedImageWithGIFData:data1];
            self.runningImageView.animatedImage = animatedImage1;
        }
    }
    else {
        self.runningImageView.animatedImage = nil;
    }
}

- (void)handleMessage:(NSDictionary*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setLabelColors:[Constants colorForHeartrate:[[message objectForKey:@"heartrate"] intValue]]];
        self.distanceLabel.text = [NSString stringWithFormat:@"%@ MI", [message objectForKey:@"distance"]];
        self.caloriesLabel.text =[NSString stringWithFormat:@"%@ CAL", [message objectForKey:@"calories"]];
        self.heartrateLabel.text =[NSString stringWithFormat:@"%@", [message objectForKey:@"heartrate"]];
        self.durationLabel.text =[NSString stringWithFormat:@"%@", [message objectForKey:@"duration"]];
        self.heartRange.text = ([[message objectForKey:@"heartrange"] length] > 0) ? [NSString stringWithFormat:@"%@ BPM", [message objectForKey:@"heartrange"]] : @"";
        self.workoutGoal.text =[NSString stringWithFormat:@"%@", [message objectForKey:@"workoutgoal"]];
        if ((self.workoutGoal.text == nil) || (self.workoutGoal.text.length == 0)) {
            self.lastTargetState = @"";
            self.currentTargetState = @"";
            self.lastWorkoutGoal = @"";
        }
        [self.heartRange setTextColor:[[Constants workoutGoalColorBands] objectForKey:self.workoutGoal.text]];
        self.targetStateLabel.text = [Constants stateForHeartrate:[[message objectForKey:@"heartrate"] intValue] andGoal:self.workoutGoal.text];
        self.currentTargetState = self.targetStateLabel.text;
        [self showRunningAnimation];
    });
    
    dispatch_async(_messageQueue, ^{
        [self.messages addEntriesFromDictionary:message];
        NSError *e = nil;
        NSData *messageData = [NSJSONSerialization
                               dataWithJSONObject:self.messages
                               options:0
                               error:&e];
        NSString *messageStr = [[NSString alloc]
                                initWithData:messageData
                                encoding:NSUTF8StringEncoding];
        
        int publishAttempts = 3;
        rtm_status stat = [self.connManager publishJson:messageStr toChannel:ChannelName];
        NSLog(@"Publish status: %d", stat);
        if (stat < 0) {
            // Reconnecting to RTM and republishing the request since the original request failed for publish
            while (publishAttempts > 0) {
                NSLog(@"Reconnecting");
                rtm_status status = [self.connManager connect];
                if (status != RTM_OK) {
                    NSLog(@"Reconnection failed");
                }
                rtm_status stat = [self.connManager publishJson:messageStr toChannel:ChannelName];
                NSLog(@"Publish status: %d", stat);
                if (stat != RTM_OK) {
                    publishAttempts--;
                } else {
                    publishAttempts = 0;
                }
            }
        }
    });
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    if (activationState == WCSessionActivationStateActivated) {
        if (_sessionActivationCompletion) {
            _sessionActivationCompletion(session);
            _sessionActivationCompletion = nil;
        }
    }
}
    
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)sessionDidDeactivate:(WCSession *)session {
    NSLog(@"Session deactivated %@", session);
}

- (void)sessionDidBecomeInactive:(WCSession *)session {
    NSLog(@"Session inactivated %@", session);
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    if (message) {
        [self handleMessage:message];
    }
}

@end
