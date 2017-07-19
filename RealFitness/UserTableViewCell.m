//
//  UserTableViewCell.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "UserTableViewCell.h"
#import "Constants.h"
@implementation UserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self updateCell];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UserDataUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UserDataUpdated object:nil];
}

- (void)notificationReceived:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    User *usr = [userInfo objectForKey:@"User"];
    if ([self.user.userid isEqualToString:usr.userid]) {
        self.user = usr;
        self.bpmLabel.text = self.user.heartrate;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateCell {
    self.userId = self.user.userid;
    self.nameLabel.text = self.user.username;
    self.bpmLabel.text = self.user.heartrate;
    self.workoutGoal = self.user.workoutgoal;
    [self animateHeart];
}

- (void)animateHeart {
    if (self.workoutGoal == nil || self.workoutGoal.length == 0) {
        [self.heartImageView setImage:[UIImage imageNamed:@"Inactive_heart0.png"]];
        self.bpmLabel.text = @"0";
        self.activeStatusLabel.text = @"Inactive";
        [self.bpmLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        self.activeStatusLabel.text = @"Active: Now";
        UIImage *heart0 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_heart0.png", [[Constants workoutGoalImagePrefix] objectForKey: self.workoutGoal]]];
        UIImage *heart1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_heart1.png", [[Constants workoutGoalImagePrefix] objectForKey: self.workoutGoal]]];
        NSArray *images = [NSArray arrayWithObjects:heart0, heart1, nil];
        self.heartImageView.animationImages = images;
        self.heartImageView.animationDuration = 1.0;
        self.heartImageView.animationRepeatCount = 0;
        [self.heartImageView startAnimating];
        [self.bpmLabel setTextColor:[[Constants workoutGoalColorBands] objectForKey:self.workoutGoal]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    [self animateHeart];
}

@end
