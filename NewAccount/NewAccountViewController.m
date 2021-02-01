//
//  NewAccountViewController.m
//  test
//
//  Created by Harsh Bhasin on 06/09/20.
//  Copyright © 2020 Harsh Bhasin. All rights reserved.
//

#import "NewAccountViewController.h"
#import "NSData+AES.h"
#import "NSString+hex.h"
//#import "AppDelegate.h"
//#import "smsViewController.h"
#import "Riot-Swift.h"
#import "WebViewViewController.h"
#import "SettingsViewController.h"

@interface NewAccountViewController (){
   
}

@end

@implementation NewAccountViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [AppDelegate theDelegate].masterTabBarController.navigationItem.title = @"Menu";
    
    [[self tabBarItem] setTitle:@"Home"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AppDelegate theDelegate].masterTabBarController.navigationItem.title = @"Menu";
    
    newCollectionView.dataSource = self;
    newCollectionView.delegate = self;
        
    recipePhotos = [NSArray arrayWithObjects:@"wallet.png",
                    @"profile.png",
                    @"invite-friends1.png",
                    @"voucher-recharge.png",
                    @"transfer-credit.png",
                    @"transfer-history.png",
                    @"airtime.png",
                    @"data-bundle.png",
                    @"electricy-bill-pay.png",
                    @"tv-bill.png",
                    @"send-sms.png",
                    @"privacy.png",
                    @"why.png",
                    @"logout.png",
                  nil];
        
    itemNameArray = [NSArray arrayWithObjects:@"Wallet Balance",
                     @"Profile",
                     @"Invite Friend",
                     @"Voucher Recharge",
                     @"Transfer Credit",
                     @"Transfer Credit History",
                     @"International Mobile Airtime Toupup",
                     @"Data Bundle Toupup",
                     @"Electricity Bill's Payement",
                     @"Television Bill's Paymant",
                     @"Send SMS",
                     @"Privacy Policy",
                     @"Why This App?",
                     @"Logout",
                    nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
     UIView *bgView = (UIView *)[cell viewWithTag:1];
    
    if (indexPath.row == 0 ||indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 7 || indexPath.row == 8 || indexPath.row == 11 || indexPath.row == 12) {
        bgView.backgroundColor = [UIColor colorWithRed: 0.17 green: 0.36 blue: 0.56 alpha: 1.00];
    }
    else {
        bgView.backgroundColor = [UIColor colorWithRed: 0.66 green: 0.84 blue: 0.93 alpha: 1.00];
    }
   
     UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:2];
     recipeImageView.image = [UIImage imageNamed:[recipePhotos objectAtIndex:indexPath.row]];
    UILabel *textlbl = (UILabel *)[cell viewWithTag:3];
    textlbl.text = [itemNameArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return recipePhotos.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width/2) , 170);
  // return  CGSizeMake(120, 200);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *Username = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    NSString *Password =[[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
    
    switch (indexPath.row) {
            
        case 0:
            [self performSegueWithIdentifier:@"ToOldAccount" sender:self];
            break;
                
        case 1: {
            
        SettingsViewController *obj = [[SettingsViewController alloc] init];
        [self.navigationController pushViewController:obj animated:YES];
            
        break;
    }

        case 2: {
            
            //// Invite Friend
            
            NSString *textToShare = @"Join me on GOIP2Call, this free video chat and messaging app is amazing. I like it!";
            NSURL *myWebsite = [NSURL URLWithString:@"http://play.google.com/store/apps/details?id=com.goipcall"];

            NSArray *objectsToShare = @[textToShare, myWebsite];

            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

            NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                           UIActivityTypePrint,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypePostToFlickr,
                                           UIActivityTypePostToVimeo];

            activityVC.excludedActivityTypes = excludeActivities;

            [self presentViewController:activityVC animated:YES completion:nil];

            break;
        }

        case 3:
          //Voucher Recharge
            [self VoucherRecharge];
            break;
          
           case 4:
            //// balance transfer
            [self BalanceTransfer];
         
            break;
           
            case 5:
             // Tranfer HIstory
            [self TransferHistory];
            break;
           
            case 6:
         //International Mobile Airtime Toupees A
            [self BuyCredit:[NSString stringWithFormat:@"https://www.goip2call.com/crm/customer/billing_mobile_app.php?pr_login=%@&pr_password=%@&mobiledone=submit_log",Username,Password] title:[itemNameArray objectAtIndex:indexPath.row]];
                 
            break;
            
            case 7:
          // Data Bundle Toupup
            [self BuyCredit:[NSString stringWithFormat:@"https://www.goip2call.com/crm/customer/billing_mobile_data_app.php?pr_login=%@&pr_password=%@&mobiledone=submit_log",Username,Password] title:[itemNameArray objectAtIndex:indexPath.row]];
                 
            break;
           
        case 8:
          
           // Electricity Bill's
            [self BuyCredit:[NSString stringWithFormat:@"https://www.goip2call.com/crm/customer/billing_electricity_app.php?pr_login=%@&pr_password=%@&mobiledone=submit_log",Username,Password] title:[itemNameArray objectAtIndex:indexPath.row]];
         
            break;

        case 9:
       //Television Bill's Paymant
            [self BuyCredit:[NSString stringWithFormat:@"https://www.goip2call.com/crm/customer/billing_television_app.php?pr_login=%@&pr_password=%@&mobiledone=submit_log",Username,Password] title:[itemNameArray objectAtIndex:indexPath.row]];
                
         break;
            
            case 10:
            
            //Send SMS
            
            [self BuyCredit:[NSString stringWithFormat:@"https://www.goip2call.com/crm/customer/sendsms_app.php?pr_login=%@&pr_password=%@&mobiledone=submit_log",Username,Password] title:[itemNameArray objectAtIndex:indexPath.row]];

        break;

        case 11:
        
        //privacy
        
        [self BuyCredit:[NSString stringWithFormat:@"https://goip2call.live-website.com/contact/privacy-policy/"] title:[itemNameArray objectAtIndex:indexPath.row]];

    break;

        case 12:
        
        //why
        
        [self BuyCredit:[NSString stringWithFormat:@"https://goip2call.live-website.com/"] title:[itemNameArray objectAtIndex:indexPath.row]];

    break;

        case 13: {
        
        //logout
            
            [[AppDelegate theDelegate] logoutWithConfirmation:NO completion:nil];

    break;

        }
        default:
            break;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *) collectionView
                        layout:(UICollectionViewLayout *) collectionViewLayout
        insetForSectionAtIndex:(NSInteger) section {

    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}




-(void)sendSms{
    /*
    NSUserDefaults *segue = [NSUserDefaults standardUserDefaults];
                  [segue setObject:[NSString stringWithFormat:@"%@",@"1"] forKey:@"yes"];
        [segue synchronize];
                  
    smsViewController * wvc = [[smsViewController alloc] init];
    [self presentViewController:wvc animated:NO completion:Nil];*/
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

-(void)TransferHistory {
    
    [self performSegueWithIdentifier:@"showTransferNew" sender:self];
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
    if(([Username isEqualToString:@"919896693647"]) || ([Username isEqualToString:@"919896693648"])){
    
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




-(void)BuyCredit:(NSString*)str title:(NSString*)title{
    
    NSString *Username = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    NSString *Password =[[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
  
    if(([Username isEqualToString:@"919896693647"]) || ([Username isEqualToString:@"919896693648"])){
    
            UIAlertView *alert78 = [[UIAlertView alloc]  initWithTitle:@"Alert"
             message:@"Under Development."
             delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: Nil];
        
        
             [alert78 show];
        
    
    }else{
        WebViewViewController *webViewViewController = [[WebViewViewController alloc] initWithURL:str];
        
        webViewViewController.title = title;//NSLocalizedStringFromTable(@"settings_term_conditions", @"Vector", nil);
        [self.navigationController pushViewController:webViewViewController animated:true];
    }
 
    //[self.navigationController pushViewController:webViewViewController];
}

-(void)backAct
{
   
}

-(void)GetBalance{
    
    
    NSString *cust_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    
    NSString *cust_pass = [[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
    
    
    if(!(([cust_id isEqualToString:@"919362222111"]) || ([cust_id isEqualToString:@"919999569605"]))){
    
    
    
    [_balanceIndicator startAnimating];
    
   // _lblbalance.hidden=YES;
    
    
    
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
                        
                       // _lblbalance.text =[formatter stringFromNumber:bal];//67
                        [_balanceIndicator stopAnimating];
                        _balanceIndicator.hidden=YES;
                       // _lblbalance.hidden=NO;
                        
                        
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
