//
//  SharingViewController.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "SharingViewController.h"
#import "User.h"
#import "SatoriConnectionManager.h"
#import "Constants.h"
#import "RealFitness-Swift.h"
#import "UserTableViewCell.h"
#import "UserActivityViewController.h"

@interface SharingViewController () {
    dispatch_queue_t _messageQueue;
}
@property (nonatomic, strong) NSMutableArray<User *> *users;
@property (nonatomic, strong) SatoriConnectionManager *connMgr;
@property (nonatomic, strong) SubscriptionDataHandler messageHandler;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*> *userDict;
@property (nonatomic, strong) NSMutableDictionary<NSString*, UIImage*> *userAvatar;
@end

@implementation SharingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.connMgr = [SatoriConnectionManager sharedManager];
    _messageQueue = dispatch_queue_create("usersubscriptionqueue", DISPATCH_QUEUE_CONCURRENT);
    self.users = [NSMutableArray<User *> new];
    self.userDict = [NSMutableDictionary<NSString*, NSNumber*> new];
    self.userAvatar = [NSMutableDictionary<NSString*, UIImage*> new];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator startAnimating];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [self.view bringSubviewToFront:activityIndicator];
    
    
    __weak SharingViewController *weakSelf = self;
    self.messageHandler = ^(NSDictionary *body, NSDictionary *error) {
        if (body) {
            [activityIndicator stopAnimating];
            NSError *error = nil;
            NSDictionary* msg = [[body objectForKey:@"messages"] objectAtIndex:0];
            User *user = [[User alloc] initWithDictionary:msg error:&error];
            if (error) {
                NSLog(@"Error parsing user info %@", error);
            }
            else {
                NSNumber *indx = [weakSelf.userDict objectForKey:user.userid];
                if (indx == nil) {
                    NSUInteger index = weakSelf.users.count;
                    [weakSelf.users addObject:user];
                    [weakSelf.userDict setObject:[NSNumber numberWithInteger:index] forKey:user.userid];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                }
                else {
                    [weakSelf.users replaceObjectAtIndex:[indx intValue] withObject:user];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:UserDataUpdated object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:user, @"User", nil]];
                    });
                }
            }
        }
    };
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    for (UserTableViewCell *cell in self.tableView.visibleCells) {
        [cell animateHeart];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak SharingViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSDictionary *body = [[NSDictionary alloc] initWithObjectsAndKeys: @"select * from `Fitness`", @"filter", ChannelName, @"subscription_id", [NSNumber numberWithInt:1], @"period", nil];
        rtm_status stat = [weakSelf.connMgr subscribeWithBody:body withMessageHandler:weakSelf.messageHandler];
        if (stat != RTM_OK) {
            NSLog(@"Error subscribing to %@", ChannelName);
        }
        
        while ([weakSelf.connMgr.rtm poll] >= 0) {
            sleep(1);
        }
    });
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    User *user = [self.users objectAtIndex:indexPath.row];
    if ([self.userAvatar objectForKey:user.userid] != nil) {
        [cell.avatarImageView setImage:[self.userAvatar objectForKey:user.userid]];
    }
    else {
        [cell.avatarImageView setImageForNameWithString:user.username backgroundColor:nil circular:YES textAttributes:nil];
        [self.userAvatar setObject:cell.avatarImageView.image forKey:user.userid];
    }
    cell.user = user;
    [cell updateCell];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [self.users objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UserActivityViewController *userActivityController = [storyboard instantiateViewControllerWithIdentifier:@"UserActivityViewController"];
    userActivityController.userId = user.userid;
    userActivityController.userName = user.username;
    [self.navigationController pushViewController:userActivityController animated:YES];
}

@end
