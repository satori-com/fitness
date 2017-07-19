//
//  Constants.h
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef Constants_h
#define Constants_h

static NSString* WeightLoss = @"Weight Loss";
static NSString* LongDistance = @"Long Distance";
static NSString* Recreational = @"Recreational";
static NSString* Interval = @"Interval";

static NSString* AboveTarget = @"Above Target";
static NSString* BelowTarget = @"Below Target";
static NSString* OnTarget = @"On Target";

static NSString* Url = @"YOUR_ENDPOINT";
static NSString* AppKey = @"YOUR_APPKEY";
static NSString* ChannelName = @"Fitness";

static NSString* Subscription_id = @"subscription_id";
static NSString* UserDataUpdated = @"UserDataUpdated";

static NSString* ReactionLoveIt = @"Love it";
static NSString* ReactionGoSlow = @"Go slow";
static NSString* ReactionGoFast = @"Go fast";
static NSString* ReactionQuick = @"You are quick";

#endif /* Constants_h */

@interface Constants : NSObject

+ (NSArray*)workoutGoals;
+ (NSDictionary*)reactionImages;
+ (NSDictionary*)workoutGoalColorBands;
+ (UIColor*)colorForHeartrate:(int)rate;
+ (NSDictionary*)heartRateRanges;
+ (NSDictionary*)workoutGoalImagePrefix;
+ (NSString*)stateForHeartrate:(int)rate andGoal:(NSString*)workoutGoal;
+ (NSString*)getAnimationImagePrefixForState:(NSString*)currentState;
@end
