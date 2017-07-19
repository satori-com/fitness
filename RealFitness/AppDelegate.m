//
//  AppDelegate.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <HealthKit/HealthKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UINavigationBar appearance].barStyle = UIBarStyleBlackOpaque;
    [self.window setTintColor:[UIColor colorWithRed:255/255.0 green:51/255.0 blue:102/255.0 alpha:1.0]];
    return YES;
}

@end
