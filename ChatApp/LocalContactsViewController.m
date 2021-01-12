//
//  NSObject+LocalContactsViewController.m
//  Riot
//
//  Created by Arun on 06/03/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import "LocalContactsViewController.h"
#import "ContactSync.h"
#import "LocalContactsTableViewCell.h"
#import "LocalContacts.h"
#import "Riot-Swift.h"

#import "NBPhoneNumberUtil.h"
#import "NSData+AES.h"
#import "NSString+hex.h"
#import "ContactSync.h"

@implementation LocalContactsViewController
@synthesize ContactsArray,SelectedContacts,StartChatButton,Username,mainSession;
-(void)viewDidLoad{
    self.navigationController.navigationBar.backgroundColor = ThemeService.shared.theme.headerBackgroundColor;
    self.view.backgroundColor = ThemeService.shared.theme.backgroundColor;
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (granted){
            
            
            UsersAddressBook = ABAddressBookCreateWithOptions(NULL, nil);
            
            //contains details for all the contacts
            ContactInfoArray = ABAddressBookCopyArrayOfAllPeople(UsersAddressBook);
        }});
    ContactsArray =[[ContactSync getSharedInstance]GetLocalContacts];
    [self.tableView reloadData];
    SelectedContacts = [[NSMutableArray alloc]init];
    [StartChatButton setEnabled:YES];
    Username = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    StartChatButton.title = @"Sync";
}
-(void)viewWillAppear:(BOOL)animated{
    ContactsArray =[[ContactSync getSharedInstance]GetLocalContacts];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ContactsArray count];
}
-(NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (hours>0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocalContactsTableViewCell *cell = (LocalContactsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"localContactCell"];
    LocalContacts *localContacts =[ContactsArray objectAtIndex:indexPath.row];
    cell.backgroundColor = ThemeService.shared.theme.backgroundColor;
    // Configure the cell...
    [cell.Name setText: localContacts.Name];
    [cell.Number setText:[@"+" stringByAppendingString:localContacts.PhoneNo]];
    cell.ContactimageView.image=[UIImage imageNamed: @"profilepicture.png"];
    cell.ContactSelectedImageView.image = NULL;
    for(int i=0;i<SelectedContacts.count;i++){
        if (localContacts==[SelectedContacts objectAtIndex:i]) {
            cell.ContactSelectedImageView.image = [UIImage imageNamed: @"camera_record.png"];
            break;
        }
    }
    if(ContactInfoArray!=nil){
        //get the total number of count of the users contact
        //CFIndex numberofPeople = CFArrayGetCount(ContactInfoArray);
        if (localContacts.ContactREF!=nil) {
            
            
            int i = [localContacts.ContactREF intValue];
            
            ABRecordRef ref = CFArrayGetValueAtIndex(ContactInfoArray, i);
            
            NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
            if (lastName !=nil) {
                firstName = [firstName stringByAppendingFormat:@" %@",lastName];
            }
            
            UIImage *iimage;
            
            //if person has image store it
            if (ABPersonHasImageData(ref)) {
                
                CFDataRef imageData=ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
                iimage = [UIImage imageWithData:(__bridge NSData *)imageData];
                
            }
            
            //set image and name
            if (iimage!=nil)
                cell.ContactimageView.image=iimage;
            cell.Name.text=firstName;
            
        }else{
            cell.Number.text = @"Unknown";
        }
        
        
    }
    
    cell.ContactimageView.layer.cornerRadius = cell.ContactimageView.frame.size.width / 2;
    cell.ContactimageView.layer.masksToBounds = YES;
    //cell.imageView.layer.borderWidth = 1.0f;
    cell.ContactimageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LocalContacts *localContacts =[ContactsArray objectAtIndex:indexPath.row];
    BOOL hasFound = NO;
    for(int i=0;i<SelectedContacts.count;i++){
        if (localContacts==[SelectedContacts objectAtIndex:i]) {
            hasFound=YES;
            [SelectedContacts removeObjectAtIndex:i];
            break;
        }
    }
    
    if(!hasFound && ![localContacts.PhoneNo isEqualToString:Username])
        [SelectedContacts addObject:localContacts];
    
    [tableView reloadData];
    if(SelectedContacts.count>0){
        [StartChatButton setEnabled:YES];
        if (SelectedContacts.count==1) {
            StartChatButton.title = @"Start Chat";
        }else{
            StartChatButton.title = @"Create Room";
        }
    }
    else
        StartChatButton.title = @"Sync";
        //[StartChatButton setEnabled:NO];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction)CancelButtonClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)StartChatButtonClicked:(id)sender{
    StartChatButton.enabled=NO;
    
    mainSession = [AppDelegate theDelegate].mainSession;
    
    if(SelectedContacts.count==1){
        [self addPendingActionMask];
        LocalContacts *localContacts =[SelectedContacts objectAtIndex:0];
        NSString *memberId = [NSString stringWithFormat:@"@%@:%@",localContacts.PhoneNo,RiotSettings.shared.chatDomain];
        NSArray *directRoomIds = self.mainSession.directRooms[memberId];
        NSMutableArray *directChatsArray =[[NSMutableArray alloc]init];
        for (NSString* directRoomId in directRoomIds)
        {
            if ([self.mainSession roomWithRoomId:directRoomId])
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
    }else if(SelectedContacts.count>1){
        [self GetRoomNameAndCreateRoom];
    }else{
        //Sync Contacts
        [self StartContactSync];
    }
    
}

-(void)GetRoomNameAndCreateRoom{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Create Room" message:@"Enter the Room Name" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Create Room" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *RoomName = [[alert textFields]objectAtIndex:0].text;
        if (RoomName.length>0) {
            [self addPendingActionMask];
            NSMutableArray *invites = [[NSMutableArray alloc]init];
            /*
            for (int i=0; i<SelectedContacts.count; i++) {
                LocalContacts *localContacts =[SelectedContacts objectAtIndex:i];
                NSString *memberId = [NSString stringWithFormat:@"@%@:%@",localContacts.PhoneNo,RiotSettings.shared.chatDomain];
                [invites addObject:memberId];
            }*/
            
            [mainSession createRoom:RoomName visibility:kMXRoomDirectoryVisibilityPrivate roomAlias:nil topic:nil success:^(MXRoom *room) {
                for (int i=0; i<SelectedContacts.count; i++) {
                    LocalContacts *localContacts =[SelectedContacts objectAtIndex:i];
                    NSString *memberId = [NSString stringWithFormat:@"@%@:%@",localContacts.PhoneNo,RiotSettings.shared.chatDomain];
                    [room inviteUser:memberId success:^{
                        
                    } failure:^(NSError *error) {
                        
                    }];
                }
                [[AppDelegate theDelegate]showRoom:room.roomId andEventId:nil withMatrixSession:mainSession];
                [self dismissViewControllerAnimated:YES completion:nil];
            } failure:^(NSError *error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            /* Arun
            [mainSession createRoom:RoomName visibility:kMXRoomDirectoryVisibilityPrivate roomAlias:nil topic:nil invite:[invites copy] invite3PID:nil isDirect:NO preset:kMXRoomPresetTrustedPrivateChat success:^(MXRoom *room) {
                [[AppDelegate theDelegate]showRoom:room.roomId andEventId:nil withMatrixSession:mainSession];
                [self dismissViewControllerAnimated:YES completion:nil];
            } failure:^(NSError *error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            */
        }else{
            [self GetRoomNameAndCreateRoom];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Room Name";
    }];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)addPendingActionMask
{
    
    
    // Add a spinner above the tableview to avoid that the user tap on any other button
    pendingMaskSpinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    pendingMaskSpinnerView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
    pendingMaskSpinnerView.frame = CGRectMake(0, 0, 50, 50);
    pendingMaskSpinnerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    pendingMaskSpinnerView.center = self.tableView.center;
    pendingMaskSpinnerView.layer.cornerRadius = 5.0;
    
    // append it
    [self.tableView.superview addSubview:pendingMaskSpinnerView];
    
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

-(void)StartContactSync{
    [self addPendingActionMask];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
        [self performSelectorInBackground:@selector(SyncContacts:) withObject:(__bridge id _Nullable)(addressBook)];
    }
    
    if (accessGranted) {
        [self performSelectorInBackground:@selector(SyncContacts:) withObject:(__bridge id _Nullable)(addressBook)];
    }
    
}

-(void)SyncContacts:(ABAddressBookRef )addressBook {
    ContactSync *contactSync = [ContactSync getSharedInstance];
    [contactSync DeleteAll];
    LIMIT = 100;
    AllPhoneNos = [self getContactsWithAddressBook:addressBook];
    
    int val = AllPhoneNos.count % LIMIT;
    val = val == 0 ? 0 : 1;
    TotalPages = (int)(AllPhoneNos.count / LIMIT) + val;
    CurrentPage = 0;
    //   DoSync([self LoadList:CurrentPage];
    [self DoSync:[self LoadList:CurrentPage]];
    
}
-(void)SyncCompleted{
    ContactsArray =[[ContactSync getSharedInstance]GetLocalContacts];
    [self.tableView reloadData];
    StartChatButton.enabled=YES;
    pendingMaskSpinnerView.alpha = 0;
    [pendingMaskSpinnerView removeFromSuperview];
    pendingMaskSpinnerView = NULL;
}
-(void)DoSync:(NSString *)PhoneNos{
    
    
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *isoCountryCode = [locale objectForKey: NSLocaleCountryCode];
    NSString *callingCode = [NSString stringWithFormat:@"%@", [[NBPhoneNumberUtil sharedInstance] getCountryCodeForRegion:isoCountryCode].stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@",callingCode];
    NSArray *ModifiedPhoneNOS = [AllPhoneNos filteredArrayUsingPredicate:predicate];
    NSString *PhoneNOs = [ModifiedPhoneNOS componentsJoinedByString:@","];
    
    NSString *Username = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
    NSString *Password = [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"];
    
    NSString *key = RiotSettings.shared.encKey;
    NSData *plain = [Username dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipher = [plain AES128EncryptedDataWithKey:key];
    NSString *base64Encoded = [cipher base64EncodedStringWithOptions:0];
    NSString *hexUsername = [base64Encoded stringToHex:base64Encoded];
    
    plain = [Password dataUsingEncoding:NSUTF8StringEncoding];
    cipher = [plain AES128EncryptedDataWithKey:key];
    base64Encoded = [cipher base64EncodedStringWithOptions:0];
    NSString *hexPassword = [base64Encoded stringToHex:base64Encoded];
    
    NSString *post = [NSString stringWithFormat:@"username=%@&password=%@&phonenos=%@",hexUsername,hexPassword,PhoneNOs];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url_string = RiotSettings.shared.contactSyncUrl;
    [request setURL:[NSURL URLWithString:url_string]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"requestReply: %@", requestReply);
        if(data!=nil)
        {
            if(requestReply!=nil||![requestReply isEqual:@""])
            {
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSArray *ArrPhoneNos = [json objectForKey:@"phonenos"];
                if(ArrPhoneNos!=nil){
                    ContactSync *contactSync = [ContactSync getSharedInstance];
                    for(int i=0;i<ArrPhoneNos.count;i++){
                        [contactSync AddContact:[ArrPhoneNos objectAtIndex:i] ContactName:[self getContactNameFromPhoneNumber:[ArrPhoneNos objectAtIndex:i]]];
                    }
                    
                }
                CurrentPage=CurrentPage+1;
                if(CurrentPage<TotalPages)
                    [self DoSync:[self LoadList:CurrentPage]];
                else
                    [self performSelectorOnMainThread:@selector(SyncCompleted) withObject:nil waitUntilDone:YES];
                
            }
            
        }
    }] resume];
}
-(NSString *)LoadList:(int)number{
    
    NSString *PhoneNos = @"";
    PhoneNos =[AllPhoneNos componentsJoinedByString:@","];
    
    //    int start = number * LIMIT;
    //    for(int i=start;i<(start)+LIMIT;i++)
    //    {
    //        if(i==start){
    //            PhoneNos = [AllPhoneNos objectAtIndex:i];
    //        }else if(i<AllPhoneNos.count)
    //        {
    //            PhoneNos = [PhoneNos stringByAppendingFormat:@",%@",[AllPhoneNos objectAtIndex:i]];
    //        }
    //        else
    //        {
    //            break;
    //        }
    //    }
    return PhoneNos;
}

- (NSArray *)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    
    NSMutableArray *contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSLocale *locale = [NSLocale currentLocale];
    NSString *isoCountryCode = [locale objectForKey: NSLocaleCountryCode];
    for (int i=0;i < nPeople;i++) {
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        NSString* PhoneNo;
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++) {
            PhoneNo = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j);
            if(PhoneNo.length>0){
                
                NBPhoneNumber *nbPhoneNumber = [[NBPhoneNumberUtil sharedInstance] parse:PhoneNo defaultRegion:isoCountryCode error:nil];
                NSString *formattedNumber = [[NBPhoneNumberUtil sharedInstance] format:nbPhoneNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
                NSString *prefix = @"+";
                if ([formattedNumber hasPrefix:prefix])
                {
                    // Format the display phone number
                    PhoneNo = [formattedNumber substringFromIndex:prefix.length];
                }
                [contactList addObject:PhoneNo];
            }
        }
    }
    //NSLog(@"Contacts = %@",contactList);
    return [contactList copy];
}

-(NSString *)getContactNameFromPhoneNumber:(NSString *)PhNo{
    
    NSString *ContactName=@"";
    
    ABAddressBookRef UsersAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(UsersAddressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }else { // We are on iOS 5 or Older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        CFArrayRef ContactInfoArray = ABAddressBookCopyArrayOfAllPeople(UsersAddressBook);
        
        if(ContactInfoArray!=nil){
            //get the total number of count of the users contact
            CFIndex numberofPeople = CFArrayGetCount(ContactInfoArray);
            
            //iterate through each record and add the value in the array
            for (int i =0; i<numberofPeople; i++) {
                ABRecordRef ref = CFArrayGetValueAtIndex(ContactInfoArray, i);
                NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
                NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
                if (lastName !=nil) {
                    firstName = [firstName stringByAppendingFormat:@" %@",lastName];
                }
                ABMultiValueRef multi = ABRecordCopyValue(ref, kABPersonPhoneProperty);
                
                NSString* phone;
                for (CFIndex j=0; j < ABMultiValueGetCount(multi); j++) {
                    phone=nil;
                    phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(multi, j);
                    phone =[[[[[phone stringByReplacingOccurrencesOfString:@"-" withString:@"" ]stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""];
                    phone = [phone stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                                options:NSRegularExpressionSearch
                                                                  range:NSMakeRange(0, [phone length])];
                    NSString *searchnumber =PhNo;
                    searchnumber =[[[[[searchnumber stringByReplacingOccurrencesOfString:@"-" withString:@"" ]stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""];
                    searchnumber = [searchnumber stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                                              options:NSRegularExpressionSearch
                                                                                range:NSMakeRange(0, [searchnumber length])];
                    if([searchnumber rangeOfString:phone].location != NSNotFound){
                        return firstName;
                    }
                }
            }
        }
    }
    return ContactName;
}

@end
