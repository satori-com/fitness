//
//  UserTableViewCell.h
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "RealFitness-Swift.h"

@interface UserTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *bpmLabel;
@property (strong, nonatomic) IBOutlet UIImageView *heartImageView;
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *workoutGoal;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) IBOutlet UILabel *activeStatusLabel;

- (void)animateHeart;
- (void)updateCell;
@end
