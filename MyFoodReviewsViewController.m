//  Created by JS-K on 1/23/16.
//  Copyright © 2016 JS-K. All rights reserved.

#import "MyFoodReviewsViewController.h"
#import "RevmobAd.h"

@interface MyFoodReviewsViewController ()
//@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet UIView *bnView;

@end

@implementation MyFoodReviewsViewController

- (void)viewWillAppear:(BOOL)animated
{
    

    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [MyRevMobAds ShowRevmobAd:self.view hFromBottom: self.tabBarController.tabBar.frame.size.height];

//  UIWebView *webView = [[UIWebView alloc]init];//-----------------------
//    NSString *urlString = @"http://www.yelp.com/biz/angus-meat-market-la-crescenta-montrose";
    NSString *urlString = [NSString stringWithFormat:@"http://www.yelp.com/biz/%@", self.restaurant.id];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    self.webview.scalesPageToFit = YES;
    self.title = self.restaurant.name;
    [self.webview loadRequest:urlRequest];
//        [self.view addSubview:self.webview];

   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
