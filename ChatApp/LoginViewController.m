//
//  NSObject+LoginViewController.m
//  Riot
//
//  Created by Arun on 28/02/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import "LoginViewController.h"
#import "ThemeService.h"
#import "Riot-Swift.h"
#import "Tools.h"

#import "CountryPickerViewController.h"
#import "NBPhoneNumberUtil.h"

#import "RiotNavigationController.h"
#import "NSData+AES.h"
#import "NSString+hex.h"
#import <MatrixSDK/MatrixSDK.h>
@interface LoginViewController ()
{
    
    UINavigationController *phoneNumberPickerNavigationController;
    CountryPickerViewController *phoneNumberCountryPicker;
    NBPhoneNumber *nbPhoneNumber;
    
    UIView *modalView;
    
    MXRestClient *mxRestClient;
    MXHTTPOperation *mxCurrentOperation;
}
@end
@implementation LoginViewController

#pragma mark - View Design & Loading
-(void)viewDidLoad{
    [self customizeViewRendering];
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    self.isoCountryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    [self setIsoCountryCode:self.isoCountryCode];
    
    
}

-(void)customizeViewRendering
{
    
//    self.phoneTextField.textColor = kRiotPrimaryTextColor;
//
//    self.isoCountryCodeLabel.textColor = kRiotPrimaryTextColor;
//    self.callingCodeLabel.textColor = kRiotPrimaryTextColor;
    
    self.view.backgroundColor = ThemeService.shared.theme.backgroundColor;
    self.phoneTextField.textColor = ThemeService.shared.theme.textPrimaryColor;
    self.otpTextField.textColor = ThemeService.shared.theme.textPrimaryColor;
    
    self.isoCountryCodeLabel.textColor = ThemeService.shared.theme.textPrimaryColor;
    self.callingCodeLabel.textColor = ThemeService.shared.theme.textPrimaryColor;
    
    if (ThemeService.shared.theme.placeholderTextColor)
    {
        if (self.phoneTextField.placeholder)
        {
            self.phoneTextField.attributedPlaceholder = [[NSAttributedString alloc]
                                                         initWithString:self.phoneTextField.placeholder
                                                         attributes:@{NSForegroundColorAttributeName: ThemeService.shared.theme.placeholderTextColor}];
        }
        
    }
}

#pragma mark -
- (IBAction)selectPhoneNumberCountry:(id)sender
{
    
    phoneNumberCountryPicker = [CountryPickerViewController countryPickerViewController];
    phoneNumberCountryPicker.delegate = self;
    phoneNumberCountryPicker.showCountryCallingCode = YES;
    
    phoneNumberPickerNavigationController = [[UINavigationController alloc] initWithRootViewController:phoneNumberCountryPicker];
    
    // Set Riot navigation bar colors
    phoneNumberPickerNavigationController.navigationBar.barTintColor = ThemeService.shared.theme.backgroundColor;
    NSDictionary<NSString *,id> *titleTextAttributes = phoneNumberPickerNavigationController.navigationBar.titleTextAttributes;
    if (titleTextAttributes)
    {
        NSMutableDictionary *textAttributes = [NSMutableDictionary dictionaryWithDictionary:titleTextAttributes];
        textAttributes[NSForegroundColorAttributeName] = ThemeService.shared.theme.placeholderTextColor;
        phoneNumberPickerNavigationController.navigationBar.titleTextAttributes = textAttributes;
    }
    else if (ThemeService.shared.theme.placeholderTextColor)
    {
        phoneNumberPickerNavigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: ThemeService.shared.theme.placeholderTextColor};
    }
    
    //[phoneNumberPickerNavigationController pushViewController:phoneNumberCountryPicker animated:NO];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissCountryPicker)];
    phoneNumberCountryPicker.navigationItem.leftBarButtonItem = leftBarButtonItem;
    [self presentViewController:phoneNumberPickerNavigationController animated:YES completion:nil];
    
    //[self.navigationController pushViewController:phoneNumberPickerNavigationController animated:YES];
    //[self presentViewController:phoneNumberPickerNavigationController];
}

#pragma mark - MXKCountryPickerViewControllerDelegate

- (void)countryPickerViewController:(MXKCountryPickerViewController *)countryPickerViewController didSelectCountry:(NSString *)isoCountryCode { 
    self.isoCountryCode = isoCountryCode;
    
    nbPhoneNumber = [[NBPhoneNumberUtil sharedInstance] parse:self.phoneTextField.text defaultRegion:isoCountryCode error:nil];
    [self setIsoCountryCode:isoCountryCode];
    [self formatNewPhoneNumber];
    
    [self dismissCountryPicker];
}
#pragma mark -
- (void)setIsoCountryCode:(NSString *)isoCountryCode
{
    _isoCountryCode = isoCountryCode;
    
    NSNumber *callingCode = [[NBPhoneNumberUtil sharedInstance] getCountryCodeForRegion:isoCountryCode];
    
    self.callingCodeLabel.text = [NSString stringWithFormat:@"+%@", callingCode.stringValue];
    
    self.isoCountryCodeLabel.text = isoCountryCode;
    
    // Update displayed phone
    [self textFieldDidChange:self.phoneTextField];
}
- (void)dismissCountryPicker
{
    [phoneNumberCountryPicker withdrawViewControllerAnimated:YES completion:nil];
    [phoneNumberCountryPicker destroy];
    phoneNumberCountryPicker = nil;
    
    [phoneNumberPickerNavigationController dismissViewControllerAnimated:YES completion:nil];
    phoneNumberPickerNavigationController = nil;
}
- (void)formatNewPhoneNumber
{
    if (nbPhoneNumber)
    {
        NSString *formattedNumber = [[NBPhoneNumberUtil sharedInstance] format:nbPhoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:nil];
        NSString *prefix = self.callingCodeLabel.text;
        if ([formattedNumber hasPrefix:prefix])
        {
            // Format the display phone number
            self.phoneTextField.text = [formattedNumber substringFromIndex:prefix.length];
        }
    }
}
- (IBAction)textFieldDidChange:(id)sender
{
    UITextField* textField = (UITextField*)sender;
    
    if (textField == self.phoneTextField)
    {
        nbPhoneNumber = [[NBPhoneNumberUtil sharedInstance] parse:self.phoneTextField.text defaultRegion:self.isoCountryCode error:nil];
        
        [self formatNewPhoneNumber];
    }
}

- (IBAction)nextButtonClick:(id)sender{
    /*
     modalView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
     modalView.opaque = NO;
     modalView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
     CGRect screenRect = [[UIScreen mainScreen] bounds];
     CGFloat screenWidth = screenRect.size.width;
     CGFloat screenHeight = screenRect.size.height;
     
     UILabel *label = [[UILabel alloc] init];
     label.frame=CGRectMake(0, screenHeight/2, screenWidth, 50);
     label.text = @"Please wait...";
     label.textColor = [UIColor whiteColor];
     label.backgroundColor = [UIColor clearColor];
     label.opaque = NO;
     //[label sizeToFit];
     label.textAlignment=NSTextAlignmentCenter;
     [modalView addSubview:label];
     [self.view addSubview:modalView];
     [self performSelectorInBackground:@selector(RequestOTP) withObject:nil];
     */
    [self RequestOTP];
}

- (IBAction)verifyButtonClick:(id)sender{
    [self VerifyOTP];
}


//light blue : #00afef  Dark code: #3e4095


#pragma mark - API Calls

-(void)RequestOTP{
    
    [_phoneTextField resignFirstResponder];
    if([[NBPhoneNumberUtil sharedInstance] isPossibleNumber:nbPhoneNumber]){
        
        NSString *ccode = [[[NBPhoneNumberUtil sharedInstance] getCountryCodeForRegion:self.isoCountryCode] stringValue];
        
        NSString *phone = [[NBPhoneNumberUtil sharedInstance] format:nbPhoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
        NSString *prefix = self.callingCodeLabel.text;
        if ([phone hasPrefix:prefix])
        {
            phone = [phone substringFromIndex:prefix.length];
        }
        
        NSString *key = RiotSettings.shared.encKey;
        NSData *plain = [ccode dataUsingEncoding:NSUTF8StringEncoding];
        NSData *cipher = [plain AES128EncryptedDataWithKey:key];
        NSString *base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexccode = [base64Encoded stringToHex:base64Encoded];
        
        plain = [phone dataUsingEncoding:NSUTF8StringEncoding];
        cipher = [plain AES128EncryptedDataWithKey:key];
        base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexphone = [base64Encoded stringToHex:base64Encoded];
        
//        plain = [@"dfdf@g.com" dataUsingEncoding:NSUTF8StringEncoding];
//        cipher = [plain AES128EncryptedDataWithKey:key];
//        base64Encoded = [cipher base64EncodedStringWithOptions:0];
//        NSString *hexEmail = [base64Encoded stringToHex:base64Encoded];
//
 //       NSString *post = [NSString stringWithFormat:@"ccode=%@&phone=%@&email=%@",hexccode,hexphone,hexEmail];
         NSString *post = [NSString stringWithFormat:@"ccode=%@&phone=%@",hexccode,hexphone];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *url_string = RiotSettings.shared.otpRequestUrl;
        [request setURL:[NSURL URLWithString:url_string]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"requestReply: %@", requestReply);
            if(data==nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert78 = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Please Make sure you have a Working Internet Connection."
                                                                     delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
                    
                    
                    [alert78 show];
                });
            }
            else
            {
                if(requestReply!=nil||![requestReply isEqual:@""])
                {
                    
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@",json);
                    if(json!=nil)
                    {
                        NSString *result =[json objectForKey:@"result"];
                        NSString *msg = [json objectForKey:@"OTP"];
                        if([result isEqualToString:@"success"]){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [UIView transitionWithView:_LoginContainer
                                                  duration:0.4
                                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                                animations:^{
                                                    _LoginContainer.hidden = YES;
                                                }
                                                completion:NULL];
                                [UIView transitionWithView:_OTPContainer
                                                  duration:0.4
                                                   options:UIViewAnimationOptionShowHideTransitionViews
                                                animations:^{
                                                    _OTPContainer.hidden = NO;
                                                }
                                                completion:NULL];
                                [_otpTextField becomeFirstResponder];
                                //int msg1 = [[json objectForKey:@"otpinfo"]intValue];
                               
                                UIAlertView *alert78 = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                                  message:msg
                                                                                 delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: Nil];
                                
                                
                                [alert78 show];
                                
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIAlertView *alert78 = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                                  message:msg
                                                                                 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
                                
                                
                                [alert78 show];
                            });
                        }
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert78 = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                              message:@"An error occured please try again later."
                                                                             delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
                            
                            
                            [alert78 show];
                        });
                        
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
                                                                           message:@"Please Make sure you have a Working Internet Connection."
                                                                          delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
                        
                        
                        [alert78 show];
                    });
                }
            }
        }] resume];
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
                                                               message:@"Please enter a valid phone number."
                                                              delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
            
            
            [alert78 show];
        });
    }
}

-(void)VerifyOTP{
    [_otpTextField resignFirstResponder];
    if(_otpTextField.text.length>=4){
        
        NSString *ccode = [[[NBPhoneNumberUtil sharedInstance] getCountryCodeForRegion:self.isoCountryCode] stringValue];
        
        NSString *phone = [[NBPhoneNumberUtil sharedInstance] format:nbPhoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
        NSString *prefix = self.callingCodeLabel.text;
        if ([phone hasPrefix:prefix])
        {
            phone = [phone substringFromIndex:prefix.length];
        }
        
        NSString *key = RiotSettings.shared.encKey ;
        NSData *plain = [ccode dataUsingEncoding:NSUTF8StringEncoding];
        NSData *cipher = [plain AES128EncryptedDataWithKey:key];
        NSString *base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexccode = [base64Encoded stringToHex:base64Encoded];
        
        plain = [phone dataUsingEncoding:NSUTF8StringEncoding];
        cipher = [plain AES128EncryptedDataWithKey:key];
        base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexphone = [base64Encoded stringToHex:base64Encoded];
        
        NSString *otp = _otpTextField.text;
        plain = [otp dataUsingEncoding:NSUTF8StringEncoding];
        cipher = [plain AES128EncryptedDataWithKey:key];
        base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexotp = [base64Encoded stringToHex:base64Encoded];
        
        NSString *post = [NSString stringWithFormat:@"ccode=%@&phone_user=%@&otp=%@",hexccode,hexphone,hexotp];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *url_string = RiotSettings.shared.otpVerifyUrl;
        [request setURL:[NSURL URLWithString:url_string]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"requestReply: %@", requestReply);
            if(data==nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert78 = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                      message:@"Please Make sure you have a Working Internet Connection."
                                                                     delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
                    
                    
                    [alert78 show];
                });
            }
            else
            {
                if(requestReply!=nil||![requestReply isEqual:@""])
                {
                    
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@",json);
                    if(json!=nil)
                    {
                        NSString *result =[json objectForKey:@"result"];
                        NSString *msg = [json objectForKey:@"OTP"];
                        if([result isEqualToString:@"success"]){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                NSString *Username =[[json objectForKey:@"userinfo"] objectForKey:@"username"];
                                NSString *Password =[[json objectForKey:@"userinfo"] objectForKey:@"password"];
                                
                                [[NSUserDefaults standardUserDefaults] setObject:Username forKey:@"Username"];
                                [[NSUserDefaults standardUserDefaults] setObject:Password forKey:@"Password"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                NSLog(@"Username: %@ --- Password: %@",Username,Password);
                                
                               
                                NSDictionary *parameters;
                                
                                
                                    parameters = @{
                                                   @"type": kMXLoginFlowTypePassword,
                                                   @"identifier": @{
                                                           @"type": kMXLoginIdentifierTypeUser,
                                                           @"user": Username
                                                           },
                                                   @"password": Password
                                                   };
                                
                                
                                
                                [self loginWithParameters:parameters];
                                
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIAlertView *alert78 = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                                  message:msg
                                                                                 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
                                
                                
                                [alert78 show];
                            });
                        }
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert78 = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                              message:@"An error occured please try again later."
                                                                             delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];


                            [alert78 show];
                        });

                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
                                                                           message:@"Please Make sure you have a Working Internet Connection."
                                                                          delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
                        
                        
                        [alert78 show];
                    });
                }
            }
        }] resume];
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
                                                               message:@"Please enter a valid OTP."
                                                              delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
            
            
            [alert78 show];
        });
    }
}

- (void)loginWithParameters:(NSDictionary*)parameters
{
    // Add the device name
    NSMutableDictionary *theParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    theParameters[@"initial_device_display_name"] = nil;
    NSString *homeserverURL = RiotSettings.shared.homeserverUrlString ;
    NSString *identityserverurl = RiotSettings.shared.identityServerUrlString;
    
    mxRestClient = [[MXRestClient alloc]initWithHomeServer:homeserverURL andOnUnrecognizedCertificateBlock:nil];
    mxRestClient.identityServer = identityserverurl;
    mxCurrentOperation = [mxRestClient login:theParameters success:^(NSDictionary *JSONResponse) {
        
        MXLoginResponse *loginResponse;
        MXJSONModelSetMXJSONModel(loginResponse, MXLoginResponse, JSONResponse);

        MXCredentials *credentials = [[MXCredentials alloc] initWithLoginResponse:loginResponse
                                                            andDefaultCredentials:self->mxRestClient.credentials];
        /// Sanity check
        if (!credentials.userId || !credentials.accessToken)
        {
            [self onFailureDuringAuthRequest:[NSError errorWithDomain:MXKAuthErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:[NSBundle mxk_localizedStringForKey:@"not_supported_yet"]}]];
        }
        else
        {
            NSLog(@"[MXKAuthenticationVC] Login process succeeded");

            // Report the certificate trusted by user (if any)
            credentials.allowedCertificate = self->mxRestClient.allowedCertificate;
            
            [self onSuccessfulLogin:credentials];
        }
        
    } failure:^(NSError *error) {
        
        [self onFailureDuringAuthRequest:error];
        
    }];
}

- (void)onSuccessfulLogin:(MXCredentials*)credentials
{
  
    mxCurrentOperation = nil;
   
    
    // Sanity check: check whether the user is not already logged in with this id
    if (![[MXKAccountManager sharedManager] accountForUserId:credentials.userId])
    {
        // Report the new account in account manager
        MXKAccount *account = [[MXKAccount alloc] initWithCredentials:credentials];
        //NSString *identityserverurl = [[NSUserDefaults standardUserDefaults] objectForKey:@"identityserverurl"];
        //account.identityServerURL = identityserverurl;
        //[account setIdentityServerURL:identityserverurl];
        
        [[MXKAccountManager sharedManager] addAccount:account andOpenSession:YES];
        if (self.authVCDelegate)
        {
            [self.authVCDelegate authenticationViewControllerDidDismiss:self];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}
-(void)onFailureDuringAuthRequest:(NSError *)error{
    UIAlertView *alert78 = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                      message:@"Login failed"
                                                     delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: Nil];
    
    
    [alert78 show];
}
@end
