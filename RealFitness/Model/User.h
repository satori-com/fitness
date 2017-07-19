//
//  User.h
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* userid;
@property (nonatomic, strong) NSString* workoutgoal;
@property (nonatomic, strong) NSString* distance;
@property (nonatomic, strong) NSString* calories;
@property (nonatomic, strong) NSString* heartrate;
@property (nonatomic, strong) NSString* heartrange;
@property (nonatomic, strong) NSString* duration;

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err;

@end
