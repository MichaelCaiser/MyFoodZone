//
//  CollectionViewController.h
//  Food Swipe
//
//  Created by JS-K on 1/23/16.
//  Copyright © 2016 JS-K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

@interface MyFoodSelViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) Restaurant *restaurant;
@property (weak, nonatomic) IBOutlet UICollectionView *myFoodSelCollection;
@property (weak, nonatomic) IBOutlet UIButton *SelectAll;
@property (weak, nonatomic) IBOutlet UIButton *Deselect;

@end
