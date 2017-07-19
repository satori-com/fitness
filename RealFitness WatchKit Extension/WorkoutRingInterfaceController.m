//
//  WorkoutRingInterfaceController.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "WorkoutRingInterfaceController.h"
#import "Constants.h"

@interface WorkoutRingInterfaceController ()
@property (nonatomic, assign) int counter;
@property (nonatomic, strong) NSString *workoutGoal;
@property (nonatomic, strong) NSString *imagePrefix;
@property (nonatomic, weak) WorkoutManager *wkManager;
@property (nonatomic, strong) NSString* lastHeartRate;
@property (nonatomic, strong) WorkoutMessageHandler handler;
@end

@implementation WorkoutRingInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self becomeCurrentPage];
    
    __weak WorkoutRingInterfaceController *weakSelf = self;
    self.handler = ^(NSDictionary *message) {
        [weakSelf processedWorkoutMessage:message];
    };
    
    // Configure interface objects here.
    if (context != nil) {
        if ([context isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary*)context;
            self.workoutGoal = [dict objectForKey:@"workoutgoal"];
        }
    }
    [self setTitle:self.workoutGoal];
    self.imagePrefix = [[Constants workoutGoalImagePrefix] objectForKey:self.workoutGoal];
    self.wkManager = [WorkoutManager sharedManagerForContext:context];
    [self.wkManager addWorkoutMessageHandler:self.handler];
    [self.bpmGroup setBackgroundImageNamed:@"Loading_BPM"];
}

- (void)animateBpmImageForHeartRate:(NSString*)heartRate {
    if ([heartRate intValue] < 40 || [heartRate intValue] > 160) {
        [self.bpmGroup setBackgroundImageNamed:@"Loading_BPM"];
    }
    else {
        [self.bpmGroup setBackgroundImageNamed:[NSString stringWithFormat:@"%@_BPM_%@_",self.imagePrefix, heartRate]];
        [self.bpmGroup startAnimatingWithImagesInRange:NSMakeRange(0, 2) duration:2.0 repeatCount:0];
    }
}
    
-(void)processedWorkoutMessage:(NSDictionary *)workoutMessage {
    if (workoutMessage) {
        NSString* heartRate = [workoutMessage objectForKey:@"heartrate"];
        if ([heartRate isEqualToString:self.lastHeartRate] == NO) {
            self.lastHeartRate = heartRate;
            [self animateBpmImageForHeartRate:heartRate];
        }
    }
}
@end



