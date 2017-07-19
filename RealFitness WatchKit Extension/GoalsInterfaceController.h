//
//  InterfaceController.h
//  RealFitness WatchKit Extension
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface GoalsInterfaceController : WKInterfaceController

@property (strong, nonatomic) IBOutlet WKInterfaceButton *weightLossButton;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *longDistButton;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *recreationalButton;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *intervalButton;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *weightLossGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *longDistGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *recreationalGroup;
@property (strong, nonatomic) IBOutlet WKInterfaceGroup *intervalGroup;

- (IBAction)didTapWeightLossButton;
- (IBAction)didTapRecreationalButton;
- (IBAction)didTapLongDistButton;
- (IBAction)didTapIntervalButton;
- (IBAction)workoutGoalPickerSelectedItemChanged:(NSInteger)value;

@end
