//
//  UIViewController+KeypadController.m
//  Cloud Play
//
//  Created by Arun on 17/04/17.
//  Copyright © 2017 Telepixels Solutions Pvt Ltd. All rights reserved.
//

#import "KeypadController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "Riot-Swift.h"
#import "Reachability.h"
#import "NSString+FontAwesome.h"
#import "RecentDB.h"
#import "NSData+AES.h"
#import "NSString+hex.h"

@implementation KeypadController
@synthesize txtPhoneNo,lblStatus,btndel,btn0;

- (void)viewDidLoad {
    
    MXKAccount* account = [MXKAccountManager sharedManager].activeAccounts.firstObject;
    MXMyUser* myUser = account.mxSession.myUser;

    _lblRegistered.text = [NSString stringWithFormat:@"Registered (%@)", myUser.displayname];
        
    txtPhoneNo.text = @"";
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [txtPhoneNo setInputView:dummyView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDel:)];
    [btndel addGestureRecognizer:longPress];
    
    UILongPressGestureRecognizer *longPress0 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress0:)];
    [btn0 addGestureRecognizer:longPress0];
    self.view.backgroundColor = ThemeService.shared.theme.backgroundColor;
}

- (void)longPressDel:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        txtPhoneNo.text=@"";
    }
}

- (void)longPress0:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateEnded) {
        if (txtPhoneNo.text.length<16)
            [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"+"];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [self GetBalance];

    [AppDelegate theDelegate].masterTabBarController.navigationItem.title = @"Direct Call";
    
    [[self tabBarItem] setTitle:@"Direct Call"];

    [self statusDidChange];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(statusDidChange) userInfo:nil repeats:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    
    [txtPhoneNo becomeFirstResponder];
}
-(void)viewDidDisappear:(BOOL)animated{
    [timer invalidate];
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField==txtPhoneNo) {
        //return NO;
        [txtPhoneNo setKeyboardAppearance:0];
    }
    return YES;
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //limit the size :
    int limit = 11;
    return !([textField.text length]>limit && [string length] > range.length);
}
-(void)dismissKeyboard
{
    [self.view endEditing:YES];
    //[txtPhoneNo becomeFirstResponder];
}

-(IBAction)KeyPress0:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"0"];
    AudioServicesPlaySystemSound(1200);
}
-(IBAction)KeyPress1:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"1"];
    
    //txtPhoneNo.text = [txtPhoneNo.text stringByAppendingString:@"1"];
    AudioServicesPlaySystemSound(1201);
}
-(IBAction)KeyPress2:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"2"];
    AudioServicesPlaySystemSound(1202);
}
-(IBAction)KeyPress3:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"3"];
    AudioServicesPlaySystemSound(1203);
}
-(IBAction)KeyPress4:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"4"];
    AudioServicesPlaySystemSound(1204);
}
-(IBAction)KeyPress5:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"5"];
    AudioServicesPlaySystemSound(1205);
}
-(IBAction)KeyPress6:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"6"];
    AudioServicesPlaySystemSound(1206);
}
-(IBAction)KeyPress7:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"7"];
    AudioServicesPlaySystemSound(1207);
}
-(IBAction)KeyPress8:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"8"];
    AudioServicesPlaySystemSound(1208);
}
-(IBAction)KeyPress9:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"9"];
    AudioServicesPlaySystemSound(1209);
}

-(IBAction)KeyPressStar:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"*"];
    AudioServicesPlaySystemSound(1210);
}
-(IBAction)KeyPressPound:(id)sender{
    if (txtPhoneNo.text.length<16)
        [txtPhoneNo replaceRange:txtPhoneNo.selectedTextRange withText:@"#"];
    AudioServicesPlaySystemSound(1211);
}
-(IBAction)KeyPressContact:(id)sender{
    
    
    if (NSClassFromString(@"CNContactPickerViewController")) {
        
        CNContactPickerViewController *contacts = [[CNContactPickerViewController alloc]init];
        contacts.displayedPropertyKeys = [NSArray arrayWithObjects: CNContactPhoneNumbersKey,nil];
        contacts.delegate=self;
        [self presentViewController:contacts animated:YES completion:^{}];
        
    }else{
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate =self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    
    
    
}


-(IBAction)KeyPressCall:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (txtPhoneNo.text.length==0) {
        txtPhoneNo.text = [[RecentDB getSharedInstance]GetLastCalledNumber];
        return;
    }
    
    if([AppDelegate theDelegate].isConnected){
        
        NSString *phoneNumber =txtPhoneNo.text;
        phoneNumber =[[[[[[phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@"" ]stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""];
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                                options:NSRegularExpressionSearch
                                                                  range:NSMakeRange(0, [phoneNumber length])];
        
        if ([phoneNumber hasPrefix:@"011"]){
            phoneNumber = [phoneNumber  stringByReplacingOccurrencesOfString:@"011" withString:@""];
        }
        if([phoneNumber hasPrefix:@"00"]){
            phoneNumber = [@"" stringByAppendingString:phoneNumber];
        }
        else{
            phoneNumber = [@"00" stringByAppendingString:phoneNumber];
        }
        
        
        if (phoneNumber.length>=10) {
            
            [[AppDelegate theDelegate] MakeCall:phoneNumber];
            [self performSegueWithIdentifier:@"showInCall" sender:self];
            
        }
        else
        {
            float os_version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (os_version >= 8.000000)
            {
                
                UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"Please check the phone number."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Please check the phone number."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
            }
        }
    }else{
        float os_version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (os_version >= 8.000000)
        {
            
            UIAlertController * alert= [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"You have not logged in. Please check the login details in settings."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"You have not logged in. Please check the login details in settings."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
        
    }
}
-(IBAction)KeyPressDel:(id)sender{
    
    [txtPhoneNo deleteBackward];
    /*
     if(txtPhoneNo.text.length>0)
     txtPhoneNo.text = [txtPhoneNo.text substringToIndex:(txtPhoneNo.text.length-1)];
     */
}
 
-(IBAction)RecentPressed:(id)sender {
 
//    RecentsViewController *obj = [[RecentsViewController alloc] init];
//    [self.navigationController pushViewController:obj animated:YES];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    __block NSString *phoneNumber;
    if (property == kABPersonPhoneProperty) {
        ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for(CFIndex i = 0; i < ABMultiValueGetCount(multiPhones); i++) {
            if(identifier == ABMultiValueGetIdentifierAtIndex (multiPhones, i)) {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                CFRelease(multiPhones);
                phoneNumber = (__bridge NSString *) phoneNumberRef;
                CFRelease(phoneNumberRef);
            }
            
        }
    }
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    
    [self EditPhoneNo:phoneNumber];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty{
    
    CNLabeledValue *phoneNumberValue = contactProperty.contact.phoneNumbers.firstObject;
    CNPhoneNumber *phoneNumber = phoneNumberValue.value;
    NSString *phoneNumberString = phoneNumber.stringValue;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self EditPhoneNo:phoneNumberString];
    NSLog(@"Contact: %@",phoneNumberString);
}

-(void)EditPhoneNo:(NSString *)phno{
    NSString *phoneNumber = phno;
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"" withString:@""];
    phoneNumber = [[[[[phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@"" ]
                     stringByReplacingOccurrencesOfString:@"("withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, [phoneNumber length])];
    
    if ([phoneNumber hasPrefix:@"011"]){
        phoneNumber = [phoneNumber  stringByReplacingOccurrencesOfString:@"011" withString:@""];
    }
    if([phoneNumber hasPrefix:@"00"]){
         phoneNumber = [@"" stringByAppendingString:phoneNumber];
    }
    else{
        phoneNumber = [@"00" stringByAppendingString:phoneNumber];
    }
    
        
        
    
  
    [txtPhoneNo setText:phoneNumber];
    
    
    /*
     __block NSString *phoneNumber = phno;
     phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"" withString:@""];
     UIAlertController *alertController = [UIAlertController
     alertControllerWithTitle:@"Edit Phone Number"
     message:@""
     preferredStyle:UIAlertControllerStyleAlert];
     
     [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
     textField.placeholder = @"Phone number";
     textField.keyboardType=UIKeyboardTypeNumberPad;
     textField.delegate=self;
     phoneNumber = [[[[[phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@"" ]
     stringByReplacingOccurrencesOfString:@"("withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
     phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"\\s" withString:@""
     options:NSRegularExpressionSearch
     range:NSMakeRange(0, [phoneNumber length])];
     
     textField.text = phoneNumber;
     }];
     if (phoneNumber.length) {
     
     
     UIAlertAction *okAction = [UIAlertAction
     actionWithTitle:@"OK"
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction *action)
     {
     UITextField *txtPhone = alertController.textFields.firstObject;
     phoneNumber = txtPhone.text;
     txtPhoneNo.text = phoneNumber;
     }];
     UIAlertAction *cancelAction = [UIAlertAction
     actionWithTitle:@"Cancel"
     style:UIAlertActionStyleDefault
     handler:nil];
     [alertController addAction:okAction];
     [alertController addAction:cancelAction];
     [self presentViewController:alertController animated:YES completion:nil];
     }
     */
}

-(void)callend{
    /*
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     [appDelegate.cXProvider reportCallWithUUID:appDelegate.CallUUID endedAtDate:[NSDate date] reason:CXCallEndedReasonRemoteEnded];
     */
}
/*
- (void)account:(SBSAccount *_Nonnull)account didReceiveIncomingCall:(SBSCall *_Nonnull)call{
    f
    NSString *ringtonePath = [[NSBundle mainBundle]
                              pathForResource:@"ringtone" ofType:@"m4r"];
    NSURL *ringtoneURL = [NSURL fileURLWithPath:ringtonePath];
    
    SBSRingtone *ringtone = [[SBSRingtone alloc]initWithURL:ringtoneURL];
    [call setRingtone:ringtone];
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.CurrentCall = call;
    appDelegate.isIncoming = YES;
    [self performSegueWithIdentifier:@"showInCall" sender:self];
    [self.parentViewController.view removeFromSuperview];
    
    
}
- (void)account:(SBSAccount *_Nonnull)account registrationDidChangeState:(SBSAccountRegistrationState)state withStatusCode:(int)code{
    [self statusDidChange];
}

*/

-(void)GetBalance {
    
    NSString *cust_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    
    NSString *cust_pass = [[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];

    if(!(([cust_id isEqualToString:@"919362222111"]) || ([cust_id isEqualToString:@"919999569605"]))){
        
    [_balanceIndicator startAnimating];
    
    _lblBalance.hidden=YES;
        
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
      
        if (data == nil)
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
            if (requestReply!=nil||![requestReply isEqual:@""])
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
                        
                        _lblBalance.text = [formatter stringFromNumber:bal];//67
                        [_balanceIndicator stopAnimating];
                        _balanceIndicator.hidden = YES;
                        _lblBalance.hidden = NO;
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

- (void)statusDidChange {
    
    if ([AppDelegate theDelegate].isConnected) {
        [lblStatus setText:@"Ready To Call"];
        [lblStatus setTextColor:[UIColor greenColor]
         ];
    }else{
        [lblStatus setText:@"Registration failed"];
        [lblStatus setTextColor:[UIColor redColor]];
    }
    /*
    SBSAccount *account = appDelegate.account;
    if (account!=nil) {
        
        switch (account.registrationState) {
                
            case SBSAccountRegistrationStateInactive: {
                [lblStatus setText:@"Inactive"];
                [lblStatus setTextColor:[UIColor redColor]];
            } break;
                
            case SBSAccountRegistrationStateFailed: {
                [lblStatus setText:@"Invalid Account Info"];
                [lblStatus setTextColor:[UIColor redColor]];
            } break;
                
            case SBSAccountRegistrationStateTrying: {
                [lblStatus setText:@"Connecting..."];
                [lblStatus setTextColor:[UIColor orangeColor]];
            } break;
                
            case SBSAccountRegistrationStateActive: {
                [lblStatus setText:@"Ready To Call"];
                [lblStatus setTextColor:[UIColor colorWithRed:0.0 green:(126.0/255.0) blue:(230.0/255.0) alpha:1.0]];
            } break;
                
            case SBSAccountRegistrationStateDisabled: {
                [lblStatus setText:@"Offline"];
                [lblStatus setTextColor:[UIColor redColor]];
            } break;
        }
    }else{
        [lblStatus setText:@"Offline"];
        [lblStatus setTextColor:[UIColor redColor]];
    }*/
}


@end
