//
//  User.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "User.h"
#define SATORI_ERROR_DOMAIN @"SatoriErrorDomain"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    if (self = [super init]) {
        if (dict == nil) {
            if (err) *err = [NSError errorWithDomain:SATORI_ERROR_DOMAIN
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey:@"Initializing user with nil input object."}];
            return nil;
        }
        
        if (![dict isKindOfClass:[NSDictionary class]]) {
            if (err) *err = [NSError errorWithDomain:SATORI_ERROR_DOMAIN code:2 userInfo:@{NSLocalizedDescriptionKey:@"Attempt to initialize User object using initWithDictionary:error: but the dictionary parameter was not an 'NSDictionary'."}];
            return nil;
        }
        
        self.userid = [dict objectForKey:@"userid"];
        self.username = [dict objectForKey:@"username"];
        self.calories = [dict objectForKey:@"calories"];
        self.distance = [dict objectForKey:@"distance"];
        self.duration = [dict objectForKey:@"duration"];
        self.heartrate = [dict objectForKey:@"heartrate"];
        self.heartrange = [dict objectForKey:@"heartrange"];
        self.workoutgoal = [dict objectForKey:@"workoutgoal"];
    }
    
    return self;
}

@end
