//
//  WokroutManager.h
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

typedef void(^WorkoutMessageHandler)(NSDictionary *messages);

@protocol WorkoutMessageDelegate <NSObject>
-(void)processedWorkoutMessage:(NSDictionary*)workoutMessage;
@end

@interface WorkoutManager : NSObject <HKWorkoutSessionDelegate>

+(instancetype)sharedManagerForContext:(NSDictionary*)context;
-(void)startWorkout;
-(void)stopWorkout;
-(void)addWorkoutMessageHandler:(WorkoutMessageHandler)handler;

@end
