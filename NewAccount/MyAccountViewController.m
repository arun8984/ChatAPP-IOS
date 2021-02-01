//
//  MyAccountViewController.m
//  Riot
//
//  Created by Arun on 05/04/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import "MyAccountViewController.h"
#import "NSData+AES.h"
#import "NSString+hex.h"
//#import "AppDelegate.h"
#import "ThemeService.h"
#import "Riot-Swift.h"
@implementation MyAccountViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    _lblbalance.text=@"";
     }

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:@"STATUSDATA"];
    
        [self GetBalance];
        UITapGestureRecognizer *MobileTopUp=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(MobileTopUp)];
        [_viewMobileTopUp addGestureRecognizer:MobileTopUp];
        
        UITapGestureRecognizer *BuyCredit=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(BuyCredit)];
        [_viewBuyCredit addGestureRecognizer:BuyCredit];
        
        UITapGestureRecognizer *VoucherRecharge=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(VoucherRecharge)];
        [_viewVoucherRecharge addGestureRecognizer:VoucherRecharge];
        
//        UITapGestureRecognizer *VoucherRechargeHistry = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(VoucherRecharge_History)];
//        [_viewVoucherRechargeHistory addGestureRecognizer:VoucherRechargeHistry];
        
        UITapGestureRecognizer *TransferHistory=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TransferHistory)];
       // [_viewTransferHistory addGestureRecognizer:TransferHistory];
        
        UITapGestureRecognizer *BalanceTransfer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(BalanceTransfer)];
       [_viewBalanceTransfer addGestureRecognizer:BalanceTransfer];
        
        //    UITapGestureRecognizer *CallHistory=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(CallHistoryfun)];
        //    [_viewCallHistory addGestureRecognizer:CallHistory];
        //
//        UITapGestureRecognizer *TopupHistory=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TopupHistoryfun)];
//        [_viewTopupHistory addGestureRecognizer:TopupHistory];
        
        
  
    
    
    
    
    
}
-(void)BalanceTransfer:(NSString *)transferaccount Amount:(NSString *)credit{
    
    if ([transferaccount isEqualToString:@""]) {
        
        UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
                                                           message:@"Please enter destination Number."
                                                          delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
        
        
        [alert78 show];
        
    }
    else if([credit isEqualToString:@""]){
        UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
                                                           message:@"Please enter amount."
                                                          delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
        
        
        [alert78 show];
    }
    
    else
        
    {
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
        
        
        NSString *cust_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
        
        NSString *cust_pass = [[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
        
        
        
        NSString *key = RiotSettings.shared.encKey;
        NSData *plain = [cust_id dataUsingEncoding:NSUTF8StringEncoding];
        NSData *cipher = [plain AES128EncryptedDataWithKey:key];
        NSString *base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexcust_id = [base64Encoded stringToHex:base64Encoded];
        
        plain = [cust_pass dataUsingEncoding:NSUTF8StringEncoding];
        cipher = [plain AES128EncryptedDataWithKey:key];
        base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexcust_pass = [base64Encoded stringToHex:base64Encoded];
        
        plain = [credit dataUsingEncoding:NSUTF8StringEncoding];
        cipher = [plain AES128EncryptedDataWithKey:key];
        base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexcredit = [base64Encoded stringToHex:base64Encoded];
        
        plain = [transferaccount dataUsingEncoding:NSUTF8StringEncoding];
        cipher = [plain AES128EncryptedDataWithKey:key];
        base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hextransferaccount = [base64Encoded stringToHex:base64Encoded];
        
        
        
        
        NSString *post = [NSString stringWithFormat:@"cust_id=%@&cust_pass=%@&credit=%@&transferaccount=%@",hexcust_id,hexcust_pass,hexcredit,hextransferaccount];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
       
        NSString *url_string = @"https://www.goip2call.com/crm/goip_api/billing_balance_transfer_balance/balance_transfer_org.php";
        [request setURL:[NSURL URLWithString:url_string]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
                        NSString *msg = [json objectForKey:@"msg"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [modalView removeFromSuperview];
                            
                            UIAlertView *alert78 = [[UIAlertView alloc] initWithTitle:@"Balance Transfer"
                                                                              message:msg
                                                                             delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: Nil];
                            [alert78 show];
                        });
                    }
                    else
                    {
                        [modalView removeFromSuperview];
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
                        [modalView removeFromSuperview];
                        UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
                                                                           message:@"Please Make sure you have a Working Internet Connection."
                                                                          delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
                        
                        
                        [alert78 show];
                    });
                }
            }
        }] resume];
    }
    
}

-(void)BalanceTransfer{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Balance Transfer" message:@"Please enter the destination number and amount to transfer." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Destination number";
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Amount";
        [textField setKeyboardType:UIKeyboardTypeDefault];
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self BalanceTransfer:[[alertController textFields][0] text] Amount:[[alertController textFields][1] text]];
        
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)TransferHistory{
    
    UIButton* Back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    Back.frame= CGRectMake(8, 15 , 80, 80);
    
    [Back setTitle:@"Back" forState:UIControlStateNormal];
    [Back setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    [Back setTitleColor:[UIColor colorWithRed: 0.00 green: 0.36 blue: 0.57 alpha: 1.00] forState:UIControlStateNormal];

    [Back addTarget:self action:@selector(backAct) forControlEvents:UIControlEventTouchUpInside];
    //[showTransfer addSubview:Back];
    
    [self performSegueWithIdentifier:@"showTransfer" sender:self];
}

-(void)VoucherRecharge{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Voucher Recharge" message:@"Please enter your voucher number." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Voucher Number";
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self VoucherRecharge:[[alertController textFields][0] text]];
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)VoucherRecharge:(NSString *)voucher{
    
    if ([voucher isEqualToString:@""]) {
        
        UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
                                                           message:@"Please enter voucher number."
                                                          delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
        
        
        [alert78 show];
        
    }
    else
        
    {
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
        
        
        NSString *cust_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
        
        NSString *cust_pass = [[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
        
        
        NSString *key = RiotSettings.shared.encKey;
        NSData *plain = [cust_id dataUsingEncoding:NSUTF8StringEncoding];
        NSData *cipher = [plain AES128EncryptedDataWithKey:key];
        NSString *base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexcust_id = [base64Encoded stringToHex:base64Encoded];
        
        plain = [cust_pass dataUsingEncoding:NSUTF8StringEncoding];
        cipher = [plain AES128EncryptedDataWithKey:key];
        base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexcust_pass = [base64Encoded stringToHex:base64Encoded];
        
        plain = [voucher dataUsingEncoding:NSUTF8StringEncoding];
        cipher = [plain AES128EncryptedDataWithKey:key];
        base64Encoded = [cipher base64EncodedStringWithOptions:0];
        NSString *hexvoucher = [base64Encoded stringToHex:base64Encoded];
        
        NSString *post = [NSString stringWithFormat:@"username=%@&password=%@&voucher=%@",hexcust_id,hexcust_pass,hexvoucher];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        
        NSString *url_string = @"https://www.goip2call.com/crm/goip_api/billing_voucher_recharge/refill_dialer_voucher.php";
        [request setURL:[NSURL URLWithString:url_string]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
                        NSString *msg = [json objectForKey:@"msg"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [modalView removeFromSuperview];
                            
                            UIAlertView *alert78 = [[UIAlertView alloc] initWithTitle:@"Voucher Recharge"
                                                                              message:msg
                                                                             delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: Nil];
                            [alert78 show];
                        });
                    }
                    else
                    {
                        [modalView removeFromSuperview];
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
                        [modalView removeFromSuperview];
                        UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
                                                                           message:@"Please Make sure you have a Working Internet Connection."
                                                                          delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: Nil];
                        
                        
                        [alert78 show];
                    });
                }
            }
        }] resume];
    }
    
}

-(void)MobileTopUp{
    NSString *Username = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    NSString *Password =[[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
    if(([Username isEqualToString:@"919999569605"]) || ([Username isEqualToString:@"919362222111"])){
    
            UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
             message:@"Under Development."
             delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: Nil];
        
        
             [alert78 show];
        
    
    }
    else{
 

     NSString *url1 = [NSString stringWithFormat:@"https://www.goip2call.com/crm/customer/billing_mobile_app.php?pr_login=%@&pr_password=%@&mobiledone=submit_log",Username,Password];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url1]];
    
    }

}

//-(void)BuyCredit{
//
//    NSString *Username = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
//    NSString *Password =[[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
//    //    NSString *url = [NSString stringWithFormat:@"http://192.95.33.62/customer/mobile_payment.php?pr_login=%@&pr_password=%@&mobiledone=submit_log",Username,Password];
//
//    NSString *url = [NSString stringWithFormat:@"https://billing.buddycommunity.net/customer/mobile_payment.php?pr_login=%@&pr_password=%@&mobiledone=submit_log",Username,Password];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//
//
//}




-(void)BuyCredit{
    
    NSString *Username = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    NSString *Password =[[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
    WebViewViewController *webViewViewController = [[WebViewViewController alloc] initWithURL:[NSString stringWithFormat:@"https://www.goip2call.com/crm/customer/mobile_payment.php?pr_login=%@&pr_password=%@&mobiledone=submit_log",Username,Password]];
    
    webViewViewController.title = @"Add Funds To Wallet";//NSLocalizedStringFromTable(@"settings_term_conditions", @"Vector", nil);
    [self.navigationController pushViewController:webViewViewController animated:true];
   
}


-(void)backAct
{
    [[self.view viewWithTag:3] removeFromSuperview];
}




-(void)GetBalance{
    
    
    NSString *cust_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    
    NSString *cust_pass = [[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
    
    
    if(!(([cust_id isEqualToString:@"919362222111"]) || ([cust_id isEqualToString:@"919999569605"]))){
    
    
    
    [_balanceIndicator startAnimating];
    
    _lblbalance.hidden=YES;
    
    
    
        NSString *key = RiotSettings.shared.encKey;
    NSData *plain = [cust_id dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipher = [plain AES128EncryptedDataWithKey:key];
    NSString *base64Encoded = [cipher base64EncodedStringWithOptions:0];
    NSString *hexcust_id = [base64Encoded stringToHex:base64Encoded];
    
    plain = [cust_pass dataUsingEncoding:NSUTF8StringEncoding];
    cipher = [plain AES128EncryptedDataWithKey:key];
    base64Encoded = [cipher base64EncodedStringWithOptions:0];
    NSString *hexcust_pass = [base64Encoded stringToHex:base64Encoded];
    
    NSString *post = [NSString stringWithFormat:@"cust_id=%@&cust_pass=%@",hexcust_id,hexcust_pass];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
   
    NSString *url_string = @"https://www.goip2call.com/crm/goip_api/billing_balance/get_balance.php";
    
    [request setURL:[NSURL URLWithString:url_string]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
                if(json!=nil)
                {
                    NSString *balance =[json objectForKey:@"credit"];
                    NSString *currency = [json objectForKey:@"currency"];
                    currency = [currency componentsSeparatedByString:@"%"][0];
                    UserCurrency = currency;
                    
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSNumber *bal = [formatter numberFromString:balance];
                    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                    [formatter setCurrencyCode:currency];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _lblbalance.text =[formatter stringFromNumber:bal];//67
                        [_balanceIndicator stopAnimating];
                        _balanceIndicator.hidden=YES;
                        _lblbalance.hidden=NO;
                        
                        
                    });
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
    
}
}



@end
