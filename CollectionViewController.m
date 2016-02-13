//
//  CollectionViewController.m
//  Food Swipe
//
//  Created by JS-K on 1/23/16.
//  Copyright © 2016 JS-K. All rights reserved.
//

#import "CollectionViewController.h"
#import "AppDelegate.h"
#import "Restaurant.h"
#import "RestaurantCell.h"
#import <AFNetworking/AFNetworking.h>
#import "RestaurantDetailViewController.h"
#import "GluttonNavigationController.h"
#import "MyFoodReviewsViewController.h"

@interface CollectionViewController () <UIViewControllerPreviewingDelegate>
@property (strong, nonatomic) NSMutableArray *restaurantsToRate;
@property (strong, nonatomic) NSMutableArray *restaurantsRated;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.collectionView registerClass:[RestaurantCell class] forCellWithReuseIdentifier:reuseIdentifier];
//    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    // Do any additional setup after loading the view.
    self.restaurantsRated = [[NSMutableArray alloc] init];
    [self registerForPreviewingWithDelegate:(id)self sourceView:self.collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
//    self.navigationController.navigationBarHidden = YES;
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
//    self.restaurantsToRate = [((AppDelegate *)[[UIApplication sharedApplication] delegate]).toRate mutableCopy];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *alreadySwiped = [[defaults objectForKey:@"swiped"] mutableCopy];
    
    NSMutableArray *seenDic = [[defaults objectForKey:@"seendictionary"] mutableCopy];
    NSDate * curDate = [NSDate date];
    
    int icount = (int)seenDic.count;
    
    for (int i=icount-1; i>=0; i--)
    {
        NSDictionary *r = [seenDic objectAtIndex:i];
        
        if (![[r objectForKey:@"isseendic"]  isEqual: @1]) {
            
            NSTimeInterval distanceBetweenDates = [curDate timeIntervalSinceDate:[r objectForKey:@"date"]];
            double secondsInAnHour = 3600;
            NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
            if (hoursBetweenDates >= 24) {
                [seenDic removeObject:r];
                [alreadySwiped removeObject:[r objectForKey:@"id"]];
            }
        }
    }
//    
//    for (NSDictionary *r in seenDic) {
//
//    }
    
    [defaults setObject:seenDic forKey:@"seendictionary"];
    [defaults synchronize];
  
    [defaults setObject:alreadySwiped forKey:@"swiped"];
    [defaults synchronize];

    
    
    
    if (![self.restaurantsToRate isEqualToArray:[defaults objectForKey:@"seendictionary"]]) {
        self.restaurantsToRate = [defaults objectForKey:@"seendictionary"];
        [self.collectionView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.restaurantsToRate count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sample.jpg"]];
    
    
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 5.0;
    cell.clipsToBounds = YES;
    
    
    NSDictionary *restaurant = [self.restaurantsToRate objectAtIndex:indexPath.row];
    
    // Configure the cell
    [cell.picLoading setHidesWhenStopped:YES];
    [cell.picLoading startAnimating];
//    [cell setBackgroundColor:[UIColor grayColor]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[restaurant objectForKey:@"imageURL"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"o.jpg"]]]];
    [requestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [cell.picLoading stopAnimating];
        cell.imageView.image = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [cell.picLoading stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"sample"];
    }];
    [requestOperation start];
    cell.restaurantNameLabel.text = [restaurant objectForKey:@"name"];
    [cell.contentView sendSubviewToBack:cell.imageView];
    
    // For the rating image - ratingURL
    AFHTTPRequestOperation *requestOperationRate = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[restaurant objectForKey:@"ratingURL"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"o.jpg"]]]];
    [requestOperationRate setResponseSerializer:[AFImageResponseSerializer serializer]];
    [requestOperationRate setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        cell.imageRating.image = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [requestOperationRate start];
    
    //======= Thumbs Up/Down ==================
    NSNumber *isSeenDic = [restaurant objectForKey:@"isseendic"];
    if([isSeenDic  isEqual: @1])
    {
        cell.imgUp.hidden = NO;
        cell.imgDown.hidden=YES;
    }else if ([isSeenDic  isEqual: @-1])
    {
        cell.imgUp.hidden = YES;
        cell.imgDown.hidden=NO;
    }else{//0
        cell.imgUp.hidden = YES;
        cell.imgDown.hidden=YES;

    }
    //======= Remove for 24 hours ==================
    
    
    
    return cell;
}

- (NSMutableArray *)restaurantsToRate {
    return _restaurantsToRate ?: [[NSMutableArray alloc] init];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if ([self.presentedViewController isKindOfClass:[RestaurantDetailViewController class]]) {
        return nil;
    }
    if (CGRectContainsPoint([self.view convertRect:self.collectionView.frame fromView:self.collectionView.superview], location)) {
        CGPoint locationInTableview = [self.collectionView convertPoint:location fromView:self.view];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:locationInTableview];
        if (indexPath) {
            UICollectionViewLayoutAttributes *cellAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
            [previewingContext setSourceRect:cellAttributes.frame];
            RestaurantDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"restaurantDetail"];
            [detail setRestaurant:[Restaurant deserialize:[self.restaurantsToRate objectAtIndex:indexPath.row]]];
            return detail;
        }
    }
    
    return nil;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"restaurantDetail"]) {
        RestaurantDetailViewController *detail = (RestaurantDetailViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        [detail setRestaurant:[Restaurant deserialize:[self.restaurantsToRate objectAtIndex:indexPath.row]]];
        [detail setSegueIdentifierUsed:segue.identifier];
    }
    else if ([segue.identifier isEqualToString:@"myFoodReviewPage" ]){
        MyFoodReviewsViewController *detail = (MyFoodReviewsViewController *)segue.destinationViewController;
//        MyFoodReviewsViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"myFoodReviews"];
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        [detail setRestaurant:[Restaurant deserialize:[self.restaurantsToRate objectAtIndex:indexPath.row]]];
        //    [detail setRestaurant:self.currentRestaurant];
//        [self.navigationController pushViewController:detail animated:YES];
    }
}


- (IBAction)myFoodReviews:(id)sender {
    
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    RestaurantDetailViewController *detail = (RestaurantDetailViewController *)viewControllerToCommit;
    [detail setSegueIdentifierUsed:@"other"];
    
    [self showViewController:detail sender:self];
}

@end
