//
//  TimerInterfaceController.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "TimerInterfaceController.h"
#import "WorkoutManager.h"

@interface TimerInterfaceController ()
@end

@implementation TimerInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    WorkoutManager *wkMgr = nil;
    if (context != nil) {
        if ([context isKindOfClass:[NSDictionary class]]) {
            wkMgr = [WorkoutManager sharedManagerForContext:(NSDictionary*)context];
        }
    }
    
    
    // Configure interface objects here.
    [self setTitle:@""];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (context != nil) {
            [wkMgr startWorkout];
            [WKInterfaceController reloadRootControllersWithNames:[NSArray arrayWithObjects:@"WorkoutStateInterfaceController", @"WorkoutRingInterfaceController",@"WorkoutInterfaceController",nil] contexts:[NSArray arrayWithObjects:context, context, context, nil]];
        }
    }];
    
    [self.groupCountdown setBackgroundImageNamed:@"countdown"];
    [self.groupCountdown startAnimatingWithImagesInRange:NSMakeRange(0, 7) duration:5.0 repeatCount:1];
}

@end



