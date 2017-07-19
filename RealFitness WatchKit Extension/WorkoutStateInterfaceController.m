//
//  WorkoutStateInterfaceController.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "WorkoutStateInterfaceController.h"
#import <HealthKit/HealthKit.h>
#import "WorkoutManager.h"

@interface WorkoutStateInterfaceController ()
@property (nonatomic, weak) HKHealthStore *healthStore;
@property (nonatomic, weak) HKWorkoutSession *workoutSession;
@property (nonatomic, weak) WorkoutManager *workoutMgr;
@end

@implementation WorkoutStateInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    if (context != nil && [context isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary*)context;
        self.workoutMgr = [WorkoutManager sharedManagerForContext:dict];
    }
}

- (void)didTapStopButton {
    [self.workoutMgr stopWorkout];
    [WKInterfaceController reloadRootControllersWithNames: [NSArray arrayWithObjects:@"GoalsInterfaceController", nil] contexts:nil];
}
    
@end



