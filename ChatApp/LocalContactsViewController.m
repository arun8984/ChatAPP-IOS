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

@implementation LocalContactsViewController
@synthesize ContactsArray,SelectedContacts,StartChatButton,Username,mainSession;

-(void)viewDidLoad {
    
    //self.navigationController.navigationBar.backgroundColor = ThemeService.shared.theme.headerBackgroundColor;
    //self.view.backgroundColor = ThemeService.shared.theme.backgroundColor;
        
    [self userInterfaceThemeDidChange];
}

- (void)userInterfaceThemeDidChange
{
    [ThemeService.shared.theme applyStyleOnNavigationBar:self.navigationController.navigationBar];
    
    // Check the table view style to select its bg color.
    self.tableView.backgroundColor = ((self.tableView.style == UITableViewStylePlain) ? ThemeService.shared.theme.backgroundColor : ThemeService.shared.theme.headerBackgroundColor);
    self.view.backgroundColor = self.tableView.backgroundColor;
    self.tableView.separatorColor = ThemeService.shared.theme.lineBreakColor;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return ThemeService.shared.theme.statusBarStyle;
}

-(void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(receiveTestNotification:)
        name:@"ContactSync"
        object:nil];

    [self removePendingActionMask];
    [self addPendingActionMask];

    ABAddressBookRef addressBook = ABAddressBookCreate();

    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (granted){
            
            UsersAddressBook = ABAddressBookCreateWithOptions(NULL, nil);
            
            //contains details for all the contacts
            ContactInfoArray = ABAddressBookCopyArrayOfAllPeople(UsersAddressBook);
        }});
        
    [[AppDelegate theDelegate].masterTabBarController SyncContacts:addressBook];
        
    SelectedContacts = [[NSMutableArray alloc]init];
    [StartChatButton setEnabled:NO];
    Username = [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];

    ContactsArray = [[ContactSync getSharedInstance] GetLocalContacts];
        
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      NSLog(@"Do some work");
        
        [self.tableView reloadData];

        [self removePendingActionMask];
    });
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.

    ContactsArray = [[ContactSync getSharedInstance] GetLocalContacts];
        
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      NSLog(@"Do some work");
        
        [self.tableView reloadData];

        [self removePendingActionMask];
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
    
    LocalContacts *localContacts = nil;
    localContacts = [ContactsArray objectAtIndex:indexPath.row];
   
    cell.backgroundColor = ThemeService.shared.theme.backgroundColor;
    // Configure the cell...
   
    cell.Name.textColor = ThemeService.shared.theme.textPrimaryColor;
  
    cell.Name.text = localContacts.Name;
    
    cell.Number.textColor = ThemeService.shared.theme.textSecondaryColor;
    [cell.Number setText:[@"+" stringByAppendingString:localContacts.PhoneNo]];
   
    cell.ContactimageView.image = [UIImage imageNamed: @"profilepicture.png"];
    cell.ContactSelectedImageView.image = NULL;
    
    for (int i = 0; i < SelectedContacts.count; i++) {
        
        if (localContacts == [SelectedContacts objectAtIndex:i]) {
            
            cell.ContactSelectedImageView.image = [UIImage imageNamed: @"camera_record.png"];
            
            break;
        }
    }
    
    if (ContactInfoArray != nil) {
        //get the total number of count of the users contact
        //CFIndex numberofPeople = CFArrayGetCount(ContactInfoArray);
        if (localContacts.ContactREF != nil) {
            
            int i = [localContacts.ContactREF intValue];
            
            ABRecordRef ref = CFArrayGetValueAtIndex(ContactInfoArray, i);
            
//            NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
//            NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
//
//            if (lastName !=nil) {
//                firstName = [firstName stringByAppendingFormat:@" %@", lastName];
//            }
            
            UIImage *iimage;
            
            if (ref != nil) {
                
                //if person has image store it
                if (ABPersonHasImageData(ref)) {
                    
                    CFDataRef imageData = ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
                    
                    iimage = [UIImage imageWithData:(__bridge NSData *)imageData];
                }
                
                //set image and name
                if (iimage != nil)
                    cell.ContactimageView.image = iimage;
               
                if (localContacts.Name != nil)
                    cell.Name.text = localContacts.Name;
            }
            
        } else {
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
    
    if (SelectedContacts.count > 0) {
        
        [StartChatButton setEnabled:YES];
        
        if (SelectedContacts.count == 1) {
            StartChatButton.title = @"Start Chat";
        }else {
            StartChatButton.title = @"Create Room";
        }
    }
    else
        [StartChatButton setEnabled:NO];
    
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
    }else{
        [self GetRoomNameAndCreateRoom];
    }
    
}

-(void)GetRoomNameAndCreateRoom {
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

- (void)removePendingActionMask
{
    if (pendingMaskSpinnerView)
    {
        [pendingMaskSpinnerView removeFromSuperview];
        pendingMaskSpinnerView = nil;
    }
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

@end
