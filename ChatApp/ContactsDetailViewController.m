// 
// Copyright 2020 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "ContactsDetailsViewController.h"

#import <Contacts/CNContactStore.h>
#import <Contacts/CNContactFetchRequest.h>

#import "ContactSync.h"

#import "LocalContactsTableViewCell.h"
#import "ContactDetailsCell.h"
#import "LocalContacts.h"
#import "NBPhoneNumberUtil.h"
#import "Riot-Swift.h"
#import "WebViewViewController.h"

@implementation ContactsDetailsViewController

@synthesize Contact, LocalContactsArray, LocalContactsCSV;

-(void)viewDidLoad {
    
    nameContainerView.layer.cornerRadius = 10;
    nameContainerView.layer.masksToBounds = true;
    nameContainerView.backgroundColor = ThemeService.shared.theme.backgroundColor;
    
    optionsContainerView.layer.cornerRadius = 10;
    optionsContainerView.layer.masksToBounds = true;
    optionsContainerView.backgroundColor = ThemeService.shared.theme.backgroundColor;

    _Name.textColor = ThemeService.shared.theme.textPrimaryColor;

    [_Name setText: [self.Contact.givenName stringByAppendingFormat:@" %@",self.Contact.familyName]];
    UIImage *image = [UIImage imageWithData:self.Contact.imageData];
  
    if (image == nil) {
        _ContactimageView.image=[UIImage imageNamed: @"profilepicture.png"];
    } else {
        _ContactimageView.image=[self imageWithImage:image scaledToFillSize:CGSizeMake(75.0f, 75.0f)];
    }
        
    _ContactimageView.layer.cornerRadius = _ContactimageView.frame.size.width / 2;
    _ContactimageView.layer.masksToBounds = YES;
    _ContactimageView.layer.borderColor = [UIColor whiteColor].CGColor;
}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    self.title = @"Contact Details";

    [ThemeService.shared.theme applyStyleOnNavigationBar:[AppDelegate theDelegate].masterTabBarController.navigationController.navigationBar];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->tblObj reloadData];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:NO animated:animated]; // Will shows Navigationbar
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    NSInteger count = 0;
    
    for (CNLabeledValue *label in self.Contact.phoneNumbers) {
        if ([label.value stringValue].length > 0) {
            count++;
        }
    }
    return count;
}

/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(100.0f, 100.0f, tableView.tableHeaderView.frame.size.width+100.0f, tableView.tableHeaderView.frame.size.height+100.0f)];
    [view setBackgroundColor:[UIColor redColor]];
    return view;
}
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactDetailsCell *cell = (ContactDetailsCell *)[tableView dequeueReusableCellWithIdentifier:@"contactNos"];
        
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.backgroundColor = ThemeService.shared.theme.backgroundColor;
        
        cell.lable.textColor = ThemeService.shared.theme.textPrimaryColor;

        cell.Number.textColor = ThemeService.shared.theme.textSecondaryColor;

        NSLocale *locale = [NSLocale currentLocale];
        NSString *isoCountryCode = [locale objectForKey: NSLocaleCountryCode];
        //NSString *callingCode = [NSString stringWithFormat:@"%@", [[NBPhoneNumberUtil sharedInstance] getCountryCodeForRegion:isoCountryCode].stringValue];
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        NSError *anError = nil;
        
        NSInteger i = 0;
        
        for (CNLabeledValue *label in self.Contact.phoneNumbers) {
           
            NSString *phone = [label.value stringValue];
            
            if ([phone length] > 0) {
               
                if (i == indexPath.row) {
                    [cell.lable setText:[self GetLableString:label]];
                    [cell.Number setText:phone];
                    NBPhoneNumber *myNumber = [phoneUtil parse:phone defaultRegion:isoCountryCode error:&anError];
                    phone = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164 error:&anError];
                    if ([self.LocalContactsCSV containsString:phone]) {
                        [cell.btnChat setEnabled:true];
                    }else{
                        [cell.btnChat setEnabled:false];
                    }
                }
                i++;
            }
        }
        [cell.btnCall setTag:indexPath.row];
        [cell.btnCall addTarget:self action:@selector(Call:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnChat setTag:indexPath.row];
        [cell.btnChat addTarget:self action:@selector(Chat:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(IBAction)smsTapped:(UIButton *)sender {
    
    NSString *Username = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    NSString *Password =[[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];

    WebViewViewController *webViewViewController = [[WebViewViewController alloc] initWithURL: [NSString stringWithFormat:@"https://www.goip2call.com/crm/customer/sendsms_app.php?pr_login=%@&pr_password=%@&mobiledone=submit_log", Username, Password]];
    
    webViewViewController.title = @"SMS"; //NSLocalizedStringFromTable(@"settings_term_conditions", @"Vector", nil);
    [self.navigationController pushViewController:webViewViewController animated:true];
}

-(IBAction)DirectCall:(UIButton *)sender {

    NSInteger i = 0;

    NSArray <CNLabeledValue<CNPhoneNumber *> *> *phoneNumbers = self.Contact.phoneNumbers;

    for (CNLabeledValue *label in self.Contact.phoneNumbers) {
        NSString *phone = [label.value stringValue];

        if ([phone length] > 0) {

            if (i == sender.tag) {

                CNLabeledValue<CNPhoneNumber *> *firstPhone = [phoneNumbers objectAtIndex:i];
                CNPhoneNumber *number = firstPhone.value;
                NSString *PhoneNo = number.stringValue;
                PhoneNo = [PhoneNo stringByReplacingOccurrencesOfString:@"+" withString:@""];
                PhoneNo = [PhoneNo stringByReplacingOccurrencesOfString:@" " withString:@""];
                PhoneNo = [PhoneNo stringByReplacingOccurrencesOfString:@"(" withString:@""];
                PhoneNo = [PhoneNo stringByReplacingOccurrencesOfString:@")" withString:@""];
                PhoneNo = [PhoneNo stringByReplacingOccurrencesOfString:@"-" withString:@""];
                [[AppDelegate theDelegate] MakeCall:PhoneNo];
                [self performSegueWithIdentifier:@"showInCall" sender:self];
            }
            i++;
        }
    }

}

-(IBAction)Video:(UIButton *)sender {
    
    [self Chat:sender];
}

-(IBAction)Call:(UIButton *)sender {
    
    [self Chat:sender];
}

-(IBAction)Chat:(UIButton *)sender {
    
    [self addPendingActionMask];
    
    NSInteger i = 0;
    NSArray <CNLabeledValue<CNPhoneNumber *> *> *phoneNumbers = self.Contact.phoneNumbers;
    NSString *PhoneNo;
    for (CNLabeledValue *label in self.Contact.phoneNumbers) {
        NSString *phone = [label.value stringValue];
        if ([phone length] > 0) {
            if (i==sender.tag) {
                CNLabeledValue<CNPhoneNumber *> *firstPhone = [phoneNumbers objectAtIndex:i];
                CNPhoneNumber *number = firstPhone.value;
                PhoneNo = number.stringValue;
            }
            i++;
        }
    }
    PhoneNo = [PhoneNo stringByReplacingOccurrencesOfString:@"+" withString:@""];
    PhoneNo = [PhoneNo stringByReplacingOccurrencesOfString:@" " withString:@""];
    PhoneNo = [PhoneNo stringByReplacingOccurrencesOfString:@"(" withString:@""];
    PhoneNo = [PhoneNo stringByReplacingOccurrencesOfString:@")" withString:@""];
    PhoneNo = [PhoneNo stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *memberId = [NSString stringWithFormat:@"@%@:%@",PhoneNo,RiotSettings.shared.chatDomain];
    NSArray *directRoomIds = [AppDelegate theDelegate].mainSession.directRooms[memberId];
    NSMutableArray *directChatsArray =[[NSMutableArray alloc]init];
    
    for (NSString* directRoomId in directRoomIds)
    {
        if ([[AppDelegate theDelegate].mainSession roomWithRoomId:directRoomId])
        {
            [directChatsArray addObject:directRoomId];
        }
    }
   
    if (directChatsArray.count==0) {
        [[AppDelegate theDelegate] createDirectChatWithUserId:memberId completion:^(void){
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }else{
        [[AppDelegate theDelegate] startDirectChatWithUserId:memberId completion:^(void){
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);

    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(NSString *)GetLableString:(CNLabeledValue *)lable{
    if ([lable.label isEqualToString:CNLabelPhoneNumberMobile]) {
        return @"mobile";
    }else if([lable.label isEqualToString:CNLabelPhoneNumberMain]){
        return @"main";
    }else if([lable.label isEqualToString:CNLabelPhoneNumberiPhone]){
        return @"iPhone";
    }
    return @"other";
}
- (void)addPendingActionMask
{
    
    
    // Add a spinner above the tableview to avoid that the user tap on any other button
    UIActivityIndicatorView *pendingMaskSpinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    pendingMaskSpinnerView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
    pendingMaskSpinnerView.frame = CGRectMake(0, 0, 50, 50);
    pendingMaskSpinnerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    pendingMaskSpinnerView.center = tblObj.center;
    pendingMaskSpinnerView.layer.cornerRadius = 5.0;
    
    // append it
    [tblObj.superview addSubview:pendingMaskSpinnerView];
    
    // animate it
    [pendingMaskSpinnerView startAnimating];
    
    // Show the spinner after a delay so that if it is removed in a short future,
    // it is not displayed to the end user.
    pendingMaskSpinnerView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        pendingMaskSpinnerView.alpha = 1;
        
    } completion:^(BOOL finished) {
    }];
}
@end
