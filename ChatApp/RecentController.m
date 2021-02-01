//
//  UIViewController+RecentController.m
//  Cloud Play
//
//  Created by Arun on 18/04/17.
//  Copyright © 2017 Telepixels Solutions Pvt Ltd. All rights reserved.
//


#import "RecentController.h"
#import "RecentCall.h"
#import "RecentDB.h"
#import "RecentCell.h"
#import "Riot-Swift.h"
#import "Reachability.h"

@implementation RecentController
@synthesize CDRData,recent_CDRData;

-(void)viewDidLoad{
    
    self.view.backgroundColor = ThemeService.shared.theme.backgroundColor;
   
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (granted){
            
            
            UsersAddressBook = ABAddressBookCreateWithOptions(NULL, nil); 
            
            //contains details for all the contacts
            ContactInfoArray = ABAddressBookCopyArrayOfAllPeople(UsersAddressBook);
        }});
    CDRData =[[RecentDB getSharedInstance]GetRecentCalls];
    [self.tableView reloadData];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [AppDelegate theDelegate].masterTabBarController.navigationItem.title = @"Recents";
    
    CDRData = [[RecentDB getSharedInstance]GetRecentCalls];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    RecentCall *recentCall =[CDRData objectAtIndex:indexPath.row];
    int callid = recentCall.CallID;
    
    CDRData = [[RecentDB getSharedInstance]DeleteRecentsCall:callid];

    
    [tableView reloadData];
   
}



//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [CDRData count];
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
    
    RecentCell *cell = (RecentCell *)[tableView dequeueReusableCellWithIdentifier:@"recentCell"];
    RecentCall *recentCall =[CDRData objectAtIndex:indexPath.row];
    cell.backgroundColor = ThemeService.shared.theme.backgroundColor;
    // Configure the cell...
    [cell.Name setText: recentCall.PhoneNo];
    [cell.Name setTextColor:ThemeService.shared.theme.textPrimaryColor];
    
    NSString *myString = recentCall.CallTime;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
    NSDate *Date = [dateFormatter dateFromString:myString];
    
    //NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EdMMM " options:0 locale:[NSLocale currentLocale]];
    //[dateFormatter setDateFormat:formatString];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSInteger seconds = [[NSTimeZone systemTimeZone] secondsFromGMT];
    [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: seconds]];
    NSString *todayString = [dateFormatter stringFromDate:Date];
    
    [cell.time setText:todayString];
    [cell.Number setText:recentCall.PhoneNo];
    
    [cell.Duration setText:[self timeFormatted:recentCall.Duration]];
    
    cell.ContactimageView.image=[UIImage imageNamed: @"profilepicture.png"];
    
    if(recentCall.CallType==0){
        cell.CallTypeimageView.image =[UIImage imageNamed: @"outgoing.png"];
    }else{
        if (recentCall.Duration==0) {
            cell.CallTypeimageView.image =[UIImage imageNamed: @"missed-call.png"];
        }else{
            cell.CallTypeimageView.image =[UIImage imageNamed: @"incoming.png"];
        }
    }
    
    if(ContactInfoArray!=nil){
        //get the total number of count of the users contact
        //CFIndex numberofPeople = CFArrayGetCount(ContactInfoArray);
        if (recentCall.ContactREF!=nil) {
            
            
            int i = [recentCall.ContactREF intValue];
            
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
    
    RecentCall *recentCall = [CDRData objectAtIndex:indexPath.row];
    NSString *phoneNumber = recentCall.PhoneNo;
    [[AppDelegate theDelegate] MakeCall:phoneNumber];
    [self performSegueWithIdentifier:@"ShowInCall" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
