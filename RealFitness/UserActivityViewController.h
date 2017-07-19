//
//  UserActivityViewController.h
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FLAnimatedImage/FLAnimatedImage.h>

@interface UserActivityViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (strong, nonatomic) IBOutlet UILabel *heartrateLabel;
@property (strong, nonatomic) IBOutlet UILabel *heartRange;
@property (strong, nonatomic) IBOutlet UILabel *workoutGoal;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *targetStateLabel;
@property (strong, nonatomic) IBOutlet UIView *goalContainerView;
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *runningImageView;
@property (strong, nonatomic) NSString *userId;
@property (nonatomic, strong) NSString *userName;

@end
