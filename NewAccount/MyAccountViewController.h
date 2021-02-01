//
//  MyAccountViewController.h
//  Riot
//
//  Created by Arun on 05/04/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MyAccountViewController:UIViewController
{
    UIView *modalView;
    NSString *UserCurrency;
}

@property (strong, nonatomic) IBOutlet UILabel *lblbalance;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *balanceIndicator;
@property (strong, nonatomic) IBOutlet UIView *viewMobileTopUp;
@property (strong, nonatomic) IBOutlet UIView *viewBuyCredit;
@property (strong, nonatomic) IBOutlet UIView *viewVoucherRecharge;
@property (strong, nonatomic) IBOutlet UIView *viewTransferHistory;
@property (strong, nonatomic) IBOutlet UIView *viewBalanceTransfer;

@end
