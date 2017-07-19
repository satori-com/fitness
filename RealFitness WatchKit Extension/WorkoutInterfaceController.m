//
//  WorkoutInterfaceController.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "WorkoutInterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface WorkoutInterfaceController ()
@property (nonatomic, strong) UIColor *wokrkoutBandColor;
@property (nonatomic, strong) NSString *heartrateRange;
@property (nonatomic, strong) NSString *workoutGoal;
@property (nonatomic, weak) WorkoutManager *wkManager;
@property (nonatomic, strong) WorkoutMessageHandler handler;
@end

@implementation WorkoutInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    __weak WorkoutInterfaceController *weakSelf = self;
    self.handler = ^(NSDictionary *message) {
        [weakSelf updateLabelsForMessage:message];
    };
    
    if (context != nil) {
        if ([context isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary*)context;
            self.wokrkoutBandColor = [dict objectForKey:@"color"];
            self.heartrateRange = [dict objectForKey:@"range"];
            self.workoutGoal = [dict objectForKey:@"workoutgoal"];
            self.wkManager = [WorkoutManager sharedManagerForContext:dict];
            [self.wkManager addWorkoutMessageHandler:self.handler];
        }
    }
    [self.heartImgGroup setBackgroundImageNamed:@"heart"];
    [self.heartImgGroup startAnimatingWithImagesInRange:NSMakeRange(0, 2) duration:1.0 repeatCount:0];
    [self setTitle:self.workoutGoal];
}

- (void)updateLabelsForMessage:(NSDictionary*)message {
    if (message) {
        NSString *distance = [message objectForKey:@"distance"];
        NSString *calories = [message objectForKey:@"calories"];
        NSString *heartrate = [message objectForKey:@"heartrate"];
        NSString *duration = [message objectForKey:@"duration"];
        [self.distanceLabel setText:distance];
        [self.caloriesLabel setText:calories];
        [self.heartbeatLabel setText:heartrate];
        [self.durationLabel setText:duration];
    }
}
    
- (void)processedWorkoutMessage:(NSDictionary *)workoutMessage{
    if (workoutMessage) {
        [self updateLabelsForMessage:workoutMessage];
    }
}
@end



