//
//  WorkoutStateInterfaceController.h
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface WorkoutStateInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceButton *stopButton;
- (IBAction)didTapStopButton;

@end
