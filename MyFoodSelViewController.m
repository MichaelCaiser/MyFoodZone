//
//  CollectionViewController.m
//  Food Swipe
//
//  Created by JS-K on 1/23/16.
//  Copyright © 2016 JS-K. All rights reserved.

#import "MyFoodSelViewController.h"
#import "AppDelegate.h"
#import "Restaurant.h"
#import "RestaurantCell.h"
#import <AFNetworking/AFNetworking.h>
#import "ShareItViewController.h"
#import "GluttonNavigationController.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>


@interface MyFoodSelViewController ()
@property (strong, nonatomic) NSMutableArray *restaurantsToRate;
@property (strong, nonatomic) NSMutableArray *restaurantsRated;

@property (nonatomic, strong) NSMutableDictionary * selectDic;
@property(nonatomic, strong)  UIDocumentInteractionController* docController;

@end

@implementation MyFoodSelViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.SelectAll.hidden = YES;
    self.Deselect.hidden = YES;
    
    self.selectDic = [[NSMutableDictionary alloc]init];
//    self.myFoodSelCollection.allowsMultipleSelection = YES;

   
    // Do any additional setup after loading the view.
    self.restaurantsRated = [[NSMutableArray alloc] init];
    [self registerForPreviewingWithDelegate:(id)self sourceView:self.myFoodSelCollection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:nil];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    NSMutableArray *seenDic = [[defaults objectForKey:@"seendictionary"] mutableCopy];
    
    int icount = (int)seenDic.count;
    
    for (int i=icount-1; i>=0; i--)
    {
        NSDictionary *r = [seenDic objectAtIndex:i];
        
        if (![[r objectForKey:@"isseendic"]  isEqual: @1]) {
            [seenDic removeObject:r];
           
        }
    }
    
    self.restaurantsToRate = seenDic;
    [self.myFoodSelCollection reloadData];

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
    cell.layer.cornerRadius = 7.0;
    cell.clipsToBounds = YES;
    
    
    NSDictionary *restaurant = [[self.restaurantsToRate objectAtIndex:indexPath.row] mutableCopy];

    // Configure the cell
    [cell.picLoading setHidesWhenStopped:YES];
    [cell.picLoading startAnimating];
//    [cell setBackgroundColor:[UIColor lightGrayColor]];
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
    
    //======= is Checked ==================
//    NSNumber *isChecked = [restaurant valueForKey:@"ischecked"];
//    if([isChecked  isEqual: @1])
//    {
//        cell.imgCheck.hidden = NO;
//    }else{//0
        cell.imgCheck.hidden = YES;
//
//    }
    
    return cell;
}

- (NSMutableArray *)restaurantsToRate {
    return _restaurantsToRate ?: [[NSMutableArray alloc] init];
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor redColor]];

    NSDictionary *restaurant = [[self.restaurantsToRate objectAtIndex:indexPath.row] mutableCopy];
    
    [self.selectDic setObject:[restaurant objectForKey:@"id"] forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];

   
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor grayColor]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:nil];
    
    [self.selectDic removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    

}


- (IBAction)selectAll:(id)sender {
    
    for (NSInteger row = 0; row < [self.myFoodSelCollection numberOfItemsInSection:0]; row++) {
        [self.myFoodSelCollection selectItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        NSDictionary *restaurant = [[self.restaurantsToRate objectAtIndex:row] mutableCopy];
        [self.selectDic setObject:[restaurant objectForKey:@"id"] forKey:[NSString stringWithFormat:@"%ld",(long)row]];

    }
 }

- (IBAction)deSelect:(id)sender {
    
    int collectonViewCount = (int)[self.myFoodSelCollection numberOfItemsInSection:0];
    for (int i=collectonViewCount; i>=0; i--) {
        [self.myFoodSelCollection deselectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] animated:YES];
        [self.selectDic removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)i]];
    }
}


- (void) displaySelectedResult
{
    NSString * keyStr =  @"sel ";
    NSArray * keyArr = [self.selectDic allKeys];
    for (NSInteger i = 0; i<keyArr.count; i++) {
        NSString * str = [keyArr objectAtIndex:i];
        keyStr = [keyStr stringByAppendingString:[NSString stringWithFormat:@"%@,",str]];
    }
    
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"<>" message:keyStr preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"AA" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    //    NSLog(@"已选择key = %@",[self.selectDic allKeys]);
}

- (IBAction)shareFacebook:(id)sender {

    NSIndexPath *indexPath = [[self.myFoodSelCollection indexPathsForSelectedItems] firstObject];
    if(indexPath)
    {
        SLComposeViewController *composePost = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeFacebook];
        [composePost setInitialText: @"Food Swipe App"];

        //--------------------------
        NSArray * keyArr = [self.selectDic allKeys];
        for (int i = 0; i<keyArr.count; i++) {
            NSString *indexstr = [keyArr objectAtIndex:i];
            
            int index = [indexstr intValue];
            UIImageView * imgFB;
            NSDictionary *restaurant = [[self.restaurantsToRate objectAtIndex:index] mutableCopy];
//            RestaurantCell *cell = [self.myFoodSelCollection dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:[NSIndexPath indexPathWithIndex:index]];
            
            AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[restaurant objectForKey:@"imageURL"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"o.jpg"]]]];
            [requestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                imgFB.image = responseObject;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                imgFB.image = [UIImage imageNamed:@"sample"];
            }];
            [requestOperation start];
            
            NSData *imageData = UIImageJPEGRepresentation(imgFB.image, 9.0);
            UIImage *postImage = [UIImage imageWithData:imageData];

            
            NSString * urlid = [self.selectDic valueForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            NSString *urlString = [NSString stringWithFormat:@"http://www.yelp.com/biz/%@", urlid];
            
            [composePost addImage:postImage];
            [composePost addURL:[NSURL URLWithString:urlString]];
            
            postImage = nil;
            imageData = nil;
            
//            NSString *message = urlString;
//            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
//            toast.backgroundColor=[UIColor redColor];
//            [toast show];
//            int duration = 1; // duration in seconds
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[toast dismissWithClickedButtonIndex:0 animated:YES];
//            });
            
            
        }
        //---------------------------
        [self presentViewController:composePost animated:YES completion:nil];
        composePost = nil;
        
    }else{
        
        //diplay message--------------
        NSString *message = @"Please select a restaurant!";
        
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        toast.backgroundColor=[UIColor redColor];
        [toast show];
        int duration = 1; // duration in seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[toast dismissWithClickedButtonIndex:0 animated:YES];
        });

    }

    
}

- (IBAction)postToTwitter:(id)sender
{
    NSIndexPath *indexPath = [[self.myFoodSelCollection indexPathsForSelectedItems] firstObject];
    if(indexPath)
    {
        SLComposeViewController *composePost = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeTwitter];
        [composePost setInitialText: @"Food Swipe App"];
        
        //--------------------------
        NSArray * keyArr = [self.selectDic allKeys];
        for (int i = 0; i<keyArr.count; i++) {
            NSString *indexstr = [keyArr objectAtIndex:i];
            
            int index = [indexstr intValue];
            UIImageView * imgFB;
            NSDictionary *restaurant = [[self.restaurantsToRate objectAtIndex:index] mutableCopy];
            //            RestaurantCell *cell = [self.myFoodSelCollection dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:[NSIndexPath indexPathWithIndex:index]];
            
            AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[restaurant objectForKey:@"imageURL"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"o.jpg"]]]];
            [requestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                imgFB.image = responseObject;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                imgFB.image = [UIImage imageNamed:@"sample"];
            }];
            [requestOperation start];
            
            NSData *imageData = UIImageJPEGRepresentation(imgFB.image, 9.0);
            UIImage *postImage = [UIImage imageWithData:imageData];
            
            
            NSString * urlid = [self.selectDic valueForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            NSString *urlString = [NSString stringWithFormat:@"http://www.yelp.com/biz/%@", urlid];
            
            [composePost addImage:postImage];
            [composePost addURL:[NSURL URLWithString:urlString]];
            
            postImage = nil;
            imageData = nil;
            
            //            NSString *message = urlString;
            //            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            //            toast.backgroundColor=[UIColor redColor];
            //            [toast show];
            //            int duration = 1; // duration in seconds
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[toast dismissWithClickedButtonIndex:0 animated:YES];
            //            });
            
            
        }
        //---------------------------
        [self presentViewController:composePost animated:YES completion:nil];
        composePost = nil;
        
    }else{
        
        //diplay message--------------
        NSString *message = @"Please select a restaurant!";
        
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        toast.backgroundColor=[UIColor redColor];
        [toast show];
        int duration = 1; // duration in seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[toast dismissWithClickedButtonIndex:0 animated:YES];
        });
        
    }
}

- (IBAction)postToInstagram:(id)sender {
    NSIndexPath *indexPath = [[self.myFoodSelCollection indexPathsForSelectedItems] firstObject];
    if(indexPath)
    {

        NSArray * keyArr = [self.selectDic allKeys];
        for (int i = 0; i<keyArr.count; i++) {
            NSString *indexstr = [keyArr objectAtIndex:i];
            
            int index = [indexstr intValue];
//            UIImageView * imgFB;
            NSDictionary *restaurant = [[self.restaurantsToRate objectAtIndex:index] mutableCopy];
            //            RestaurantCell *cell = [self.myFoodSelCollection dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:[NSIndexPath indexPathWithIndex:index]];
            
//            AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[restaurant objectForKey:@"imageURL"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"o.jpg"]]]];
//            [requestOperation setResponseSerializer:[AFImageResponseSerializer serializer]];
//            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//                imgFB.image = responseObject;
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                imgFB.image = [UIImage imageNamed:@"sample"];
//            }];
//            [requestOperation start];

        //---
//            _drawingImageView.image = _imageView.image;
//            UIImage* instaImage = [self thumbnailFromView:_drawingView];

            NSString* imagePath = [restaurant objectForKey:@"imageURL"];
//            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];    //Removes the file or directory at the specified path.
//            [UIImagePNGRepresentation(instaImage) writeToFile:imagePath atomically:YES];
//            NSLog(@"image size: %@", NSStringFromCGSize(instaImage.size));
            _docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
            _docController.name = @"Food Swipe App";
            _docController.delegate=self;
            _docController.UTI = @"com.instagram.exclusivegram";
        }
        [_docController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
        
    }else{
        
        //diplay message--------------
        NSString *message = @"Please select a restaurant!";
        
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        toast.backgroundColor=[UIColor redColor];
        [toast show];
        int duration = 1; // duration in seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{[toast dismissWithClickedButtonIndex:0 animated:YES];
        });
        
    }

    
    
}



@end
