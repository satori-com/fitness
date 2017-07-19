//
//  Constants.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "Constants.h"

@implementation Constants

+ (NSArray*)workoutGoals {
    return [NSArray arrayWithObjects:Recreational, WeightLoss, LongDistance, Interval, nil];
}

+ (NSDictionary*)workoutGoalColorBands {
    return [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:0/255.0 green:169/255.0 blue:254/255.0 alpha:1.0], Recreational,
            [UIColor colorWithRed:108/255.0 green:207/255.0 blue:0/255.0 alpha:1.0], WeightLoss,
            [UIColor colorWithRed:242/255.0 green:158/255.0 blue:18/255.0 alpha:1.0], LongDistance,
            [UIColor colorWithRed:255/255.0 green:51/255.0 blue:102/255.0 alpha:1.0], Interval, nil];
}

+ (NSDictionary*)reactionImages {
    return [[NSDictionary alloc] initWithObjectsAndKeys:[UIImage imageNamed:@"Interval_heart0"], ReactionLoveIt, [UIImage imageNamed:@"Turtle"], ReactionGoSlow, [UIImage imageNamed:@"Rabbit"],  ReactionGoFast, [UIImage imageNamed:@"Horse"], ReactionQuick, nil];
}

+ (NSDictionary*)workoutGoalImagePrefix {
    return [[NSDictionary alloc] initWithObjectsAndKeys:@"Recreational", Recreational,
            @"WeightLoss", WeightLoss,
            @"LongDistance", LongDistance,
            @"Interval", Interval, nil];
}

+ (NSDictionary*)heartRateRanges {
    return [[NSDictionary alloc] initWithObjectsAndKeys: @"90-104", Recreational,
                                                         @"105-114", WeightLoss,
                                                         @"115-133", LongDistance,
                                                         @"134-160", Interval, nil];
}

+(UIColor*)colorForHeartrate:(int)rate {
    if (rate < 90 || rate > 160) {
        return [UIColor whiteColor];
    }
    else if (rate >= 90 && rate <= 104) {
        return [[[self class] workoutGoalColorBands] objectForKey:Recreational];
    }
    else if (rate > 104 && rate <= 114) {
        return [[[self class] workoutGoalColorBands] objectForKey:WeightLoss];
    }
    else if (rate > 114 && rate <= 133) {
        return [[[self class] workoutGoalColorBands] objectForKey:LongDistance];
    }
    else if (rate > 133 && rate <= 160) {
        return [[[self class] workoutGoalColorBands] objectForKey:Interval];
    }
    return nil;
}

+(NSString*)stateForHeartrate:(int)rate andGoal:(NSString*)workoutGoal {
    if ([workoutGoal isEqualToString:Recreational]) {
        if (rate < 90) {
            return BelowTarget;
        }
        if (rate > 104) {
            return AboveTarget;
        }
        return OnTarget;
    }
    else if ([workoutGoal isEqualToString:WeightLoss]) {
        if (rate < 105) {
            return BelowTarget;
        }
        if (rate > 114) {
            return AboveTarget;
        }
        return OnTarget;
    }
    else if ([workoutGoal isEqualToString:LongDistance]) {
        if (rate < 115) {
            return BelowTarget;
        }
        if (rate > 133) {
            return AboveTarget;
        }
        return OnTarget;
    }
    else if ([workoutGoal isEqualToString:Interval]) {
        if (rate < 134) {
            return BelowTarget;
        }
        if (rate > 160) {
            return AboveTarget;
        }
        return OnTarget;
    }
    return @"";
}

+ (NSString*)getAnimationImagePrefixForState:(NSString*)currentState {
    if ([currentState isEqualToString:AboveTarget]) {
        return @"Above";
    }
    if ([currentState isEqualToString:BelowTarget]) {
        return @"Below";
    }
    if ([currentState isEqualToString:OnTarget]) {
        return @"On";
    }
    return @"";
}

@end
