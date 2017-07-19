//
//  WorkoutInterfaceController.h
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "WorkoutManager.h"

@interface WorkoutInterfaceController : WKInterfaceController <WorkoutMessageDelegate>

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *durationLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *caloriesLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *distanceLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *heartbeatLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *heartImgGroup;

@end
