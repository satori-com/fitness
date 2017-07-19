//
//  WokroutManager.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "WorkoutManager.h"
#import "SessionConnector.h"

@interface WorkoutManager ()
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) HKWorkoutSession *workoutSession;
@property (nonatomic, strong) NSDate *workoutStartDate;
@property (nonatomic, strong) NSDate *workoutEndDate;
@property (nonatomic, strong) NSMutableArray<HKQuery *> *currentQueries;
@property (nonatomic, assign) int heartRatePerMinute;
@property (nonatomic, strong) SessionConnector *sessionConnector;
@property (nonatomic, strong) HKQuantity *energyBurned;
@property (nonatomic, strong) HKQuantity *distanceTravelled;
@property (nonatomic, strong) NSString *heartrateRange;
@property (nonatomic, strong) NSString *formattedDuration;
@property (nonatomic, strong) NSString *workoutGoal;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *messageHandlers;
@end

@implementation WorkoutManager

+(instancetype)sharedManagerForContext:(NSDictionary*)context {
    static WorkoutManager *sharedWorkoutManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWorkoutManager = [[self alloc] init];
    });
    if (context != nil) {
        sharedWorkoutManager.heartrateRange = [context objectForKey:@"range"];
        sharedWorkoutManager.workoutGoal = [context objectForKey:@"workoutgoal"];
    }
    return sharedWorkoutManager;
}
    
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}
    
-(void)startWorkout {
    HKWorkoutConfiguration *workoutConfiguration = [[HKWorkoutConfiguration alloc] init];
    workoutConfiguration.activityType = HKWorkoutActivityTypeRunning;
    workoutConfiguration.locationType = HKWorkoutSessionLocationTypeOutdoor;
    
    NSError *error = nil;
    self.messageHandlers = [NSMutableArray new];
    self.workoutStartDate = [NSDate new];
    self.workoutEndDate = nil;
    self.currentQueries = [NSMutableArray new];
    self.sessionConnector = [[SessionConnector alloc] init];
    self.workoutSession = [[HKWorkoutSession alloc] initWithConfiguration:workoutConfiguration error:&error];
    if (error) {
        NSLog(@"Error starting workout session: %@", error.description);
        return;
    }
    
    self.workoutSession.delegate = self;
    self.healthStore = [HKHealthStore new];
    [self.healthStore startWorkoutSession:self.workoutSession];
}

- (void)addWorkoutMessageHandler:(WorkoutMessageHandler)handler {
    if (handler != nil) {
        [self.messageHandlers addObject:handler];
    }
}
    
- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(timerDidFire:) userInfo:nil repeats:true];
}
    
- (void)timerDidFire:(NSTimer*)timer {
    [self sendMessage];
}
    
-(void)stopTimer {
    [self.timer invalidate];
}

-(double)caloriesBurnedAsDouble {
    return [self.energyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
}
    
-(double)distanceAsDouble {
    return [self.distanceTravelled doubleValueForUnit:[HKUnit mileUnit]];
}
    
- (void)energyBurnedCaloriesToUnit:(double)calories {
    self.energyBurned = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:calories];
}
    
- (void)distanceMilesToUnit:(double)miles {
    self.distanceTravelled = [HKQuantity quantityWithUnit:[HKUnit mileUnit] doubleValue:miles];
}

- (void)resetReadings {
    self.distanceTravelled = nil;
    self.energyBurned = nil;
    self.heartRatePerMinute = 0;
    self.formattedDuration = @"";
    self.workoutGoal = @"";
    self.heartrateRange = @"";
}
    
- (void)stopWorkout {
    self.workoutEndDate = [NSDate new];
    [self resetReadings];
    [self.healthStore endWorkoutSession:self.workoutSession];
}
    
- (NSString*)formattedDuration:(NSTimeInterval)duration {
    NSDateComponentsFormatter *durationFormatter = [NSDateComponentsFormatter new];
    durationFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
    durationFormatter.allowedUnits = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour;
    durationFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    
    NSString *formattedDuration = [durationFormatter stringFromTimeInterval:duration];
    if (formattedDuration == nil) {
        return @"";
    }
    return formattedDuration;
}
    
-(NSTimeInterval)computeDurationWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate {
    NSTimeInterval duration = 0.0;
    if (startDate != nil) {
        if (endDate != nil) {
            duration += [endDate timeIntervalSinceDate:startDate];
        }
        else {
            duration += [[NSDate new] timeIntervalSinceDate:startDate];
        }
    }
    return duration;
}
    
-(void)sendMessage {
    
    double dist = [self.distanceTravelled doubleValueForUnit:[HKUnit mileUnit]];
    double cals = [self.energyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
    
    NSTimeInterval duration = [self computeDurationWithStartDate:self.workoutStartDate endDate:self.workoutEndDate];
    self.formattedDuration = [self formattedDuration:duration];
    
    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys: [NSString stringWithFormat:@"%.2f", dist], @"distance",
                             [NSString stringWithFormat:@"%.1f", cals], @"calories",
                             [NSString stringWithFormat:@"%d", self.heartRatePerMinute], @"heartrate",
                             self.formattedDuration, @"duration", self.workoutGoal, @"workoutgoal",
                             self.heartrateRange, @"heartrange", nil];
    
    for (WorkoutMessageHandler handler in self.messageHandlers) {
        handler(message);
    }
    
    [self.sessionConnector send:message];
}

- (void)processSamples:(NSArray<HKSample *>*)samples identifier:(HKQuantityTypeIdentifier)identifier {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray<HKQuantitySample *>* quantitySamples = (NSArray<HKQuantitySample *>*)samples;
        for (HKQuantitySample *sample in quantitySamples) {
            if (identifier == HKQuantityTypeIdentifierDistanceWalkingRunning) {
                double newDistance = [sample.quantity doubleValueForUnit:[HKUnit mileUnit]];
                [self distanceMilesToUnit:[self distanceAsDouble] + newDistance];
            }
            else if (identifier == HKQuantityTypeIdentifierActiveEnergyBurned) {
                double newCalories = [sample.quantity doubleValueForUnit:[HKUnit kilocalorieUnit]];
                [self energyBurnedCaloriesToUnit: [self caloriesBurnedAsDouble] + newCalories];
            }
            else if (identifier == HKQuantityTypeIdentifierHeartRate) {
                double bpm = [sample.quantity doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                self.heartRatePerMinute = (int)round(bpm);
            }
            [self sendMessage];
        }
    });
}
    
- (void)startDataQuery:(HKQuantityTypeIdentifier)quantityTypeIdentifier {
    
    NSPredicate *datePredicate = [HKQuery predicateForSamplesWithStartDate:self.workoutStartDate endDate:nil options:HKQueryOptionStrictStartDate];
    NSPredicate *devicePredicate = [HKQuery predicateForObjectsFromDevices:[NSSet setWithObject:[HKDevice localDevice]]];
    NSPredicate *queryPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:datePredicate, devicePredicate, nil]];
    
    
    void(^updateHandler)(HKAnchoredObjectQuery *query, NSArray<__kindof HKSample *> * _Nullable addedObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) = ^void(HKAnchoredObjectQuery *query, NSArray<__kindof HKSample *> * _Nullable addedObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error executing query: %@", error);
        } else {
            [self processSamples:addedObjects identifier:quantityTypeIdentifier];
        }
    };
    
    HKAnchoredObjectQuery *query = [[HKAnchoredObjectQuery alloc] initWithType:[HKObjectType quantityTypeForIdentifier:quantityTypeIdentifier]
                                                                     predicate:queryPredicate
                                                                        anchor:nil
                                                                         limit:HKObjectQueryNoLimit
                                                                resultsHandler:updateHandler];
    
    query.updateHandler = updateHandler;
    [self.healthStore executeQuery:query];
    [self.currentQueries addObject:query];
}

- (void)startDataCollection {
    [self startDataQuery:HKQuantityTypeIdentifierHeartRate];
    [self startDataQuery:HKQuantityTypeIdentifierDistanceWalkingRunning];
    [self startDataQuery:HKQuantityTypeIdentifierActiveEnergyBurned];
    [self startTimer];
}
 
- (void)stopDataCollection {
    for (HKQuery *query in self.currentQueries) {
        [self.healthStore stopQuery:query];
    }
    [self.currentQueries removeAllObjects];
    [self stopTimer];
}

# pragma mark HKWorkoutSessionDelegate methods
- (void)workoutSession:(HKWorkoutSession *)workoutSession didChangeToState:(HKWorkoutSessionState)toState fromState:(HKWorkoutSessionState)fromState date:(NSDate *)date {
    switch (toState) {
        case HKWorkoutSessionStateRunning:
        [self startDataCollection];
        break;
        
        case HKWorkoutSessionStateEnded:
        [self stopDataCollection];
        break;
        
        default:
        break;
    }
    
    [self sendMessage];
}
    
- (void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error {
    NSLog(@"Workout session failed with error: %@", error);
}
    
@end
