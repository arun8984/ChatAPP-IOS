//
//  TransferHistoryViewController.m
//  Riot
//
//  Created by Arun on 05/04/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import "TransferHistoryViewController.h"
#import "TransferCell.h"
#import "NSData+AES.h"
#import "NSString+hex.h"
#import "Riot-Swift.h"
@implementation TransferHistoryViewController


-(void)viewDidLoad{
    [self getTransferHistory];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_TransferData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TransferCell *cell = (TransferCell *)[tableView dequeueReusableCellWithIdentifier:@"TransferCell"];
    
    cell.Name.text = [[_TransferData objectAtIndex:indexPath.row]objectForKey:@"reciever"];
    cell.time.text = [[_TransferData objectAtIndex:indexPath.row]objectForKey:@"date"];
    NSString *Currency = [[_TransferData objectAtIndex:indexPath.row]objectForKey:@"currency"];
    NSString *Amount = [[_TransferData objectAtIndex:indexPath.row]objectForKey:@"amount"];
    cell.Amount.text = [Currency stringByAppendingFormat:@" %@",Amount];
    
    return cell;
}


-(void)getTransferHistory{
    NSString *cust_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    
    
    NSString *key = RiotSettings.shared.encKey;
    NSData *plain = [cust_id dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipher = [plain AES128EncryptedDataWithKey:key];
    NSString *base64Encoded = [cipher base64EncodedStringWithOptions:0];
    NSString *hexcust_id = [base64Encoded stringToHex:base64Encoded];
    
    
    
    NSString *post = [NSString stringWithFormat:@"cust_id=%@",hexcust_id];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url_string = @"https://www.goip2call.com/crm/goip_api/billing_balance_transfer_balance/balance_transfer_report.php";
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
                    
                    _TransferData = [json objectForKey:@"msg"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
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

@end
