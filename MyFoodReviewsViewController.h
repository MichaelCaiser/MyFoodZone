//
//  CollectionViewController.h
//  Food Swipe
//
//  Created by Tyler Corley on 4/4/15.
//  Copyright (c) 2015 TylerCo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

@interface MyFoodReviewsViewController : UIViewController

@property (strong, nonatomic) Restaurant *restaurant;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

