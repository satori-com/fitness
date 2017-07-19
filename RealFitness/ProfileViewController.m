//
//  ProfileViewController.m
//  RealFitness
//  Copyright © 2017 Satori Worldwide, Inc. All rights reserved.
//

#import "ProfileViewController.h"
#import <HealthKit/HealthKit.h>
#import "RealFitness-Swift.h"

@interface ProfileViewController ()
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSArray* types;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForKeyboardNotifications];
    self.nameField.delegate = self;
    self.ageField.delegate = self;
    self.weightField.delegate = self;
    self.continueButton.enabled = NO;
    self.healthStore = [[HKHealthStore alloc] init];
    self.types = [NSArray arrayWithObjects:[HKObjectType workoutType],
                  [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                  [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierActiveEnergyBurned],
                  [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
                  [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning], nil];
}

- (void)viewWillAppear:(BOOL)animated {
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor lightTextColor], NSFontAttributeName: [UIFont systemFontOfSize:12.0]};
    
    self.nameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"John Doe" attributes:attributes];
    self.weightField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"160 lbs" attributes:attributes];
    self.ageField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"25 years" attributes:attributes];
    self.continueButton.layer.cornerRadius = 6.0;
    self.avatarImageView.layer.cornerRadius = ceil(self.avatarImageView.frame.size.height/2.0);
    self.avatarImageView.clipsToBounds = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"Username"] != nil && ![self isHealthKitAccessDenied]) {
        [self showTabBarController];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}
    
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.nameField) {
        if (textField.text.length == 0) {
            self.avatarImageView.alpha = 0.5;
            [self.avatarImageView setImage:[UIImage imageNamed:@"Profile"]];
        }
        else {
            self.avatarImageView.alpha = 1.0;
            [self.avatarImageView setImageForNameWithString:textField.text backgroundColor:nil circular:NO textAttributes:nil];
        }
    }
    if (self.activeTextField == textField) {
        self.activeTextField = nil;
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
    
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.containerScrollView.contentInset = contentInsets;
    self.containerScrollView.scrollIndicatorInsets = contentInsets;
}
    
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.containerScrollView.contentInset = contentInsets;
    self.containerScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)showTabBarController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
        [self dismissViewControllerAnimated:YES completion:nil];
        [appDelegate window].rootViewController = (UITabBarController*)[storyBoard instantiateViewControllerWithIdentifier:@"TabBarController"];
    });
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (str != nil && str.length > 0){
        self.continueButton.enabled = YES;
    } else {
        self.continueButton.enabled = NO;
    }
    
    return YES;
}

- (BOOL)isHealthKitAccessDenied {
    bool isPermissionDeniedForAllTypes = NO;
    for (HKObjectType *type in self.types) {
        if ([self.healthStore authorizationStatusForType:type] == HKAuthorizationStatusSharingDenied) {
            isPermissionDeniedForAllTypes = YES;
        }
        else {
            isPermissionDeniedForAllTypes = NO;
            break;
        }
    }
    return isPermissionDeniedForAllTypes;
}

- (void)requestHealthKitPermission {
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *allTypes = [NSSet setWithArray:self.types];
        
        [self.healthStore requestAuthorizationToShareTypes:allTypes readTypes:allTypes completion:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                NSLog(@"%@", error);
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to authorize HealhKit permissions" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:NO completion:nil];
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else {
                if([self isHealthKitAccessDenied]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"HealthKit Authorization" message:@"Permission to access healthkit parameters was previously denied. Please use the Health app to allow healthkit data access." preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            [self dismissViewControllerAnimated:NO completion:nil];
                        }]];
                        [self presentViewController:alertController animated:YES completion:nil];
                    });
                }
                else {
                    [self showTabBarController];
                }
            }
        }];
    }
    else {
        NSLog(@"Health Data is not available");
    }
}
    
    
- (IBAction)beginButtonTapped:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.nameField.text forKey:@"Username"];
    [[NSUserDefaults standardUserDefaults] setObject:[[NSUUID UUID] UUIDString] forKey:@"UUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self requestHealthKitPermission];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
