//
//  NewAccountViewController.h
//  test
//
//  Created by Harsh Bhasin on 06/09/20.
//  Copyright © 2020 Harsh Bhasin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewAccountViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSArray *recipePhotos;
     NSArray *itemNameArray;
    __weak IBOutlet UICollectionView *newCollectionView;
    
        UIView *modalView;
        NSString *UserCurrency;
    
}
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *balanceIndicator;

@end

NS_ASSUME_NONNULL_END
