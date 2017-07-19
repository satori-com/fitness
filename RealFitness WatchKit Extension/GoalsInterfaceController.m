//
//  InterfaceController.m
//  RealFitness WatchKit Extension
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "GoalsInterfaceController.h"
#import "Constants.h"

@interface GoalsInterfaceController()
@property (nonatomic, strong) NSString* selectedWorkoutGoal;

@end


@implementation GoalsInterfaceController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectedWorkoutGoal = WeightLoss;
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self setTitle:@"Select Goal"];
    [self setupButtonGroupColors];
}

- (void)setupButtonGroupColors {
    [self.weightLossGroup setBackgroundColor:[[Constants workoutGoalColorBands] objectForKey:WeightLoss]];
    [self.longDistGroup setBackgroundColor:[[Constants workoutGoalColorBands] objectForKey:LongDistance]];
    [self.recreationalGroup setBackgroundColor:[[Constants workoutGoalColorBands] objectForKey:Recreational]];
    [self.intervalGroup setBackgroundColor:[[Constants workoutGoalColorBands] objectForKey:Interval]];
}

- (void)loadWorkoutInterfaceForGoal:(NSString*)workoutGoal {
    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:[[Constants workoutGoalColorBands] objectForKey:workoutGoal], @"color",
                          [[Constants heartRateRanges] objectForKey:workoutGoal], @"range",
                          workoutGoal, @"workoutgoal", nil];
    
    [WKInterfaceController reloadRootControllersWithNames: [NSArray arrayWithObjects:@"TimerInterfaceController", nil] contexts:[NSArray arrayWithObjects:dict, nil]];
}

- (IBAction)didTapWeightLossButton {
    [self loadWorkoutInterfaceForGoal:WeightLoss];
}

- (IBAction)didTapRecreationalButton {
    [self loadWorkoutInterfaceForGoal:Recreational];
}

- (void)didTapIntervalButton {
    [self loadWorkoutInterfaceForGoal:Interval];
}

-(void)didTapLongDistButton {
    [self loadWorkoutInterfaceForGoal:LongDistance];
}

- (IBAction)workoutGoalPickerSelectedItemChanged:(NSInteger)value {
    self.selectedWorkoutGoal = [[Constants workoutGoals] objectAtIndex:value];
}

@end



