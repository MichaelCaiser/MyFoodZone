//
//  SettingsViewController.m
//  Food Swipe
//
//  Created by JS-K on 1/23/16.
//  Copyright © 2016 JS-K. All rights reserved.
//
#import "RevmobAd.h"
#import "MyFoodParentViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface MyFoodParentViewController ()

@end

@implementation MyFoodParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MyRevMobAds ShowRevmobAd:self.view hFromBottom: self.tabBarController.tabBar.frame.size.height];
    
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notifyWithResult:(NSString *)result andMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:result message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)resetDefaults:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset My Food Zone?" message:@"Are you sure you want to do this? \r\nData will be lost!\r\n\r\n😲 Please restart app!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doit = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        
//        [self notifyWithResult:@"My foods are gone..." andMessage:@"Wow. Such destruction. Very heavy-handed💅🏽. I clean now."];
        NSString *message = @"My foods are gone...\r\nWow. Such destruction. Very heavy-handed💅🏽. I clean now.";
        
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        toast.backgroundColor=[UIColor redColor];
        [toast show];
        int duration = 3; // duration in seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[toast dismissWithClickedButtonIndex:0 animated:YES];
        });

        
        //diplay message--------------
//        NSString *message1 = @"😲 Please restart app!";
//        
//        UIAlertView *toast1 = [[UIAlertView alloc] initWithTitle:nil message:message1 delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
//        
//        toast1.backgroundColor=[UIColor redColor];
//        [toast1 show];
//        duration = 3; // duration in seconds
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[toast1 dismissWithClickedButtonIndex:0 animated:YES];
//        });
        //----------------------------

        exit(0);
    }];
    UIAlertAction *nah = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES
                                  completion:nil];
    }];
    [alert addAction:doit];
    [alert addAction:nah];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
