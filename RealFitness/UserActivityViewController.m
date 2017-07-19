//
//  UserActivityViewController.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "UserActivityViewController.h"
#import "SatoriConnectionManager.h"
#import "User.h"
#import "Constants.h"
#import "RealFitness-Swift.h"
#import <LGPlusButtonsViewFramework/LGPlusButtonsView.h>

@interface UserActivityViewController () {
    dispatch_queue_t _messageQueue;
}
@property (nonatomic, strong) SatoriConnectionManager *connMgr;
@property (nonatomic, strong) SubscriptionDataHandler messageHandler;
@property (nonatomic, strong) NSString *lastTargetState;
@property (nonatomic, strong) NSString *lastWorkoutGoal;
@property (nonatomic, strong) NSString *currentTargetState;
@property (strong, nonatomic) LGPlusButtonsView *plusButtonsViewNavBar;
@end

@implementation UserActivityViewController

- (void)showRunningAnimation {
    if (self.workoutGoal.text != nil && [self.workoutGoal.text length] != 0) {
        if (([self.lastTargetState isEqualToString:self.currentTargetState] == NO) || ([self.lastWorkoutGoal isEqualToString:self.workoutGoal.text] == NO)) {
            self.lastTargetState = self.currentTargetState;
            self.lastWorkoutGoal = self.workoutGoal.text;
            NSString *gifName = [NSString stringWithFormat:@"%@_%@", [Constants getAnimationImagePrefixForState:self.currentTargetState], [[Constants workoutGoalImagePrefix] objectForKey:self.workoutGoal.text]];
            NSURL *url1 = [[NSBundle mainBundle] URLForResource:gifName withExtension:@"gif"];
            NSData *data1 = [NSData dataWithContentsOfURL:url1];
            FLAnimatedImage *animatedImage1 = [FLAnimatedImage animatedImageWithGIFData:data1];
            self.runningImageView.animatedImage = animatedImage1;
        }
    }
    else {
        self.runningImageView.animatedImage = nil;
    }
}

-(void)setLabelColors:(UIColor*)color {
    [self.distanceLabel setTextColor:color];
    [self.caloriesLabel setTextColor:color];
    [self.heartrateLabel setTextColor:color];
    [self.durationLabel setTextColor:color];
}

-(void)setupReactionsButton {
    _plusButtonsViewNavBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:4
                                                           firstButtonIsPlusButton:NO
                                                                     showAfterInit:NO
                                                                     actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                              {
                                  if (_plusButtonsViewNavBar.isShowing) {
                                      NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                                      [_plusButtonsViewNavBar hideAnimated:YES completionHandler:nil];
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          
                                          NSString *messageStr = [NSString stringWithFormat: @"{\"reaction\" : \"%@\"}", [self getReactionForIndex:(int)index]];
                                          int publishAttempts = 3;
                                          rtm_status stat = [self.connMgr publishJson:messageStr toChannel:[NSString stringWithFormat:@"%@-%@",self.userId, @"Reactions"]];
                                          NSLog(@"Publish status: %d", stat);
                                          if (stat < 0) {
                                              while (publishAttempts > 0) {
                                                  NSLog(@"Reconnecting");
                                                  rtm_status status = [self.connMgr connect];
                                                  if (status != RTM_OK) {
                                                      NSLog(@"Reconnection failed");
                                                  }
                                                  rtm_status stat = [self.connMgr publishJson:messageStr toChannel:[NSString stringWithFormat:@"%@-%@",self.userId, @"Reactions"]];
                                                  NSLog(@"Publish status: %d", stat);
                                                  if (stat != RTM_OK) {
                                                      publishAttempts--;
                                                  } else {
                                                      publishAttempts = 0;
                                                  }
                                              }
                                          }
                                      });
                                  }
                              }];
    
    _plusButtonsViewNavBar.showHideOnScroll = NO;
    _plusButtonsViewNavBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
    _plusButtonsViewNavBar.position = LGPlusButtonsViewPositionTopRight;
    
    [_plusButtonsViewNavBar setDescriptionsTexts:@[@"Love it!", @"Go Slow!", @"Go Fast!", @"You are quick!"]];
    [_plusButtonsViewNavBar setButtonsImages:@[[UIImage imageNamed:@"Interval_heart0"], [UIImage imageNamed:@"Turtle"], [UIImage imageNamed:@"Rabbit"], [UIImage imageNamed:@"Horse"]] forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
    
    [_plusButtonsViewNavBar setButtonsTitleFont:[UIFont boldSystemFontOfSize:32.f] forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewNavBar setButtonsSize:CGSizeMake(52.f, 52.f) forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewNavBar setButtonsLayerCornerRadius:52.f/2.f forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewNavBar setButtonsBackgroundColor:[UIColor colorWithRed:252/255.0 green:201/255.0 blue:185/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_plusButtonsViewNavBar setButtonsBackgroundColor:[UIColor colorWithRed:240/255.0 green:143/255.0 blue:144/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [_plusButtonsViewNavBar setButtonsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
    [_plusButtonsViewNavBar setButtonsLayerShadowOpacity:0.5];
    [_plusButtonsViewNavBar setButtonsLayerShadowRadius:3.f];
    [_plusButtonsViewNavBar setButtonsLayerShadowOffset:CGSizeMake(0.f, 2.f)];
    
    [_plusButtonsViewNavBar setDescriptionsTextColor:[UIColor whiteColor]];
    [_plusButtonsViewNavBar setDescriptionsBackgroundColor:[UIColor blackColor]];
    [_plusButtonsViewNavBar setDescriptionsLayerCornerRadius:6.f forOrientation:LGPlusButtonsViewOrientationAll];
    [_plusButtonsViewNavBar setDescriptionsContentEdgeInsets:UIEdgeInsetsMake(4.f, 8.f, 4.f, 8.f) forOrientation:LGPlusButtonsViewOrientationAll];
    
    [_plusButtonsViewNavBar setButtonsSize:CGSizeMake(44.f, 44.f) forOrientation:LGPlusButtonsViewOrientationLandscape];
    [_plusButtonsViewNavBar setButtonsLayerCornerRadius:44.f/2.f forOrientation:LGPlusButtonsViewOrientationLandscape];
    [_plusButtonsViewNavBar setButtonsTitleFont:[UIFont systemFontOfSize:24.f] forOrientation:LGPlusButtonsViewOrientationLandscape];
    [self.view addSubview:_plusButtonsViewNavBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.connMgr = [SatoriConnectionManager sharedManager];
    _messageQueue = dispatch_queue_create("userdataqueue", DISPATCH_QUEUE_CONCURRENT);
    self.lastTargetState = @"";
    self.currentTargetState = @"";
    self.lastWorkoutGoal = @"";
    [self.navigationItem setTitle:self.userName];
    [self setLabelColors:[UIColor whiteColor]];
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"Bubble"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showHideButtonsAction) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 50, 50)];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 10.0, 0, 0);
    [button setImageEdgeInsets:insets];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    [self setupReactionsButton];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator startAnimating];
    activityIndicator.center = self.runningImageView.center;
    [self.view addSubview:activityIndicator];
    [self.view bringSubviewToFront:activityIndicator];
    
    __weak UserActivityViewController *weakSelf = self;
    self.messageHandler = ^(NSDictionary *body, NSDictionary *error) {
        if (body) {
            NSError *error = nil;
            NSDictionary* msg = [[body objectForKey:@"messages"] objectAtIndex:0];
            User *user = [[User alloc] initWithDictionary:msg error:&error];
            if (error) {
                NSLog(@"Error parsing user info %@", error);
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [activityIndicator stopAnimating];
                    [weakSelf setLabelColors:[Constants colorForHeartrate:[user.heartrate intValue]]];
                    weakSelf.distanceLabel.text = [NSString stringWithFormat:@"%@ MI", user.distance];
                    weakSelf.caloriesLabel.text =[NSString stringWithFormat:@"%@ CAL", user.calories];
                    weakSelf.heartrateLabel.text =[NSString stringWithFormat:@"%@", user.heartrate];
                    weakSelf.durationLabel.text =[NSString stringWithFormat:@"%@",  user.duration];
                    weakSelf.heartRange.text = ([user.heartrange length] > 0) ? [NSString stringWithFormat:@"%@ BPM", user.heartrange] : @"";
                    weakSelf.workoutGoal.text =[NSString stringWithFormat:@"%@", user.workoutgoal];
                    [weakSelf.heartRange setTextColor:[[Constants workoutGoalColorBands] objectForKey:weakSelf.workoutGoal.text]];
                    weakSelf.targetStateLabel.text = [Constants stateForHeartrate:[user.heartrate intValue] andGoal:weakSelf.workoutGoal.text];
                    weakSelf.currentTargetState = weakSelf.targetStateLabel.text;
                    [weakSelf showRunningAnimation];
                });
            }
        }
    };
    
    dispatch_async(_messageQueue, ^{
        NSDictionary *body = [[NSDictionary alloc] initWithObjectsAndKeys: [NSString stringWithFormat:@"select * from `Fitness` where userid like \"%@\"", self.userId], @"filter", self.userId, @"subscription_id", [NSNumber numberWithInt:1], @"period", nil];
        rtm_status stat = [weakSelf.connMgr subscribeWithBody:body withMessageHandler:weakSelf.messageHandler];
        if (stat != RTM_OK) {
            NSLog(@"Error subscribing to %@", ChannelName);
        }
        
        // Poll RTM to receive subscribe response
        while ([weakSelf.connMgr.rtm poll] >= 0) {
            sleep(1);
        }
    });
}

- (void)viewDidAppear:(BOOL)animated {
    self.goalContainerView.layer.cornerRadius = 6.0;
    self.goalContainerView.layer.borderWidth = 1.0;
    self.goalContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)showHideButtonsAction
{
    if (_plusButtonsViewNavBar.isShowing)
        [_plusButtonsViewNavBar hideAnimated:YES completionHandler:nil];
    else
        [_plusButtonsViewNavBar showAnimated:YES completionHandler:nil];
}

- (NSString*)getReactionForIndex:(int)index {
    switch (index) {
        case 0:
            return ReactionLoveIt;
            break;
        case 1:
            return ReactionGoSlow;
            break;
        case 2:
            return ReactionGoFast;
            break;
        case 3:
            return ReactionQuick;
            break;
            
        default:
            return ReactionLoveIt;
            break;
    }
}


@end
