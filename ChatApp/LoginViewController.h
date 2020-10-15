//
//  NSObject+LoginViewController.h
//  Riot
//
//  Created by Arun on 28/02/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import <MatrixKit/MatrixKit.h>
@protocol AuthenticationViewControllerDelegate;
@interface LoginViewController : UIViewController<MXKCountryPickerViewControllerDelegate>

@property (nonatomic, weak) id<AuthenticationViewControllerDelegate> authVCDelegate;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *otpTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UIButton *countryCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *isoCountryCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *callingCodeLabel;

@property (weak, nonatomic) IBOutlet UIView *LoginContainer;
@property (weak, nonatomic) IBOutlet UIView *OTPContainer;

@property (nonatomic) NSString *isoCountryCode;

@end

@protocol AuthenticationViewControllerDelegate <NSObject>

- (void)authenticationViewControllerDidDismiss:(LoginViewController *)authenticationViewController;

@end;
