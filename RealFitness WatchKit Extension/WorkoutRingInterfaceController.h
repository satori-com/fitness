//
//  WorkoutRingInterfaceController.h
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "WorkoutManager.h"

@interface WorkoutRingInterfaceController : WKInterfaceController <WorkoutMessageDelegate>
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *bpmGroup;

@end
