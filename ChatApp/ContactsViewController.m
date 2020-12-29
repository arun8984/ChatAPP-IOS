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

#import "ContactsViewController.h"

#import "ContactSync.h"
#import "LocalContactsTableViewCell.h"
#import "LocalContacts.h"
#import "NBPhoneNumberUtil.h"
#import "ContactsDetailsViewController.h"

#import "Riot-Swift.h"

@implementation ContactsViewController

@synthesize ContactsArray,LocalContactsArray,LocalContactsCSV,Contact;

-(void)viewDidLoad{
    LocalContactsArray =[[ContactSync getSharedInstance]GetLocalContacts];
    LocalContactsCSV = @"";
    for(int j=0;j<LocalContactsArray.count;j++){
        LocalContacts *tmpContacts =[LocalContactsArray objectAtIndex:j];
        NSString *tmpLocalPhone = [@"+" stringByAppendingString:tmpContacts.PhoneNo];
        LocalContactsCSV = [LocalContactsCSV stringByAppendingFormat:@",%@",tmpLocalPhone];
    }
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            //keys with fetching properties
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
            [request setSortOrder:CNContactSortOrderGivenName];
            
            NSError *error;
            NSMutableArray *contacts = [[NSMutableArray alloc]init];
            BOOL success = [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop) {
                if (error) {
                    NSLog(@"error fetching contacts %@", error);
                } else {
                    /*
                    ContactData *newContact = [[ContactData alloc] init];
                    newContact.FirstName = contact.givenName;
                    newContact.LastName = contact.familyName;
                    UIImage *image = [UIImage imageWithData:contact.imageData];
                    newContact.image = image;
                    NSMutableArray *phones = [[NSMutableArray alloc]init];
                    for (CNLabeledValue *label in contact.phoneNumbers) {
                        NSString *phone = [label.value stringValue];
                        if ([phone length] > 0) {
                            [phones addObject:phone];
                        }
                    }
                   
                    newContact.PhoneNos = [NSArray arrayWithArray:phones];
                    [contacts addObject:newContact];*/
                    [contacts addObject:contact];
                }
            }];
            self.ContactsArray =[NSArray arrayWithArray:contacts];
        }
    }];
    
}
-(void)viewWillAppear:(BOOL)animated{
    //[self.navigationController setNavigationBarHidden:YES animated:animated];   // Will hides Navigationbar
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
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
    LocalContactsTableViewCell *cell = (LocalContactsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    CNContact *contact =[ContactsArray objectAtIndex:indexPath.row];
    cell.backgroundColor = ThemeService.shared.theme.backgroundColor;
    // Configure the cell...
    [cell.Name setText: [contact.givenName stringByAppendingFormat:@" %@",contact.familyName]];
    UIImage *image = [UIImage imageWithData:contact.imageData];
    if(image == nil){
        cell.ContactimageView.image=[UIImage imageNamed: @"profilepicture.png"];
    }else{
        cell.ContactimageView.image=[self imageWithImage:image scaledToFillSize:CGSizeMake(50.0f, 50.0f)];
    }
    cell.ContactSelectedImageView.image = NULL;
     
     NSLocale *locale = [NSLocale currentLocale];
     NSString *isoCountryCode = [locale objectForKey: NSLocaleCountryCode];
     //NSString *callingCode = [NSString stringWithFormat:@"%@", [[NBPhoneNumberUtil sharedInstance] getCountryCodeForRegion:isoCountryCode].stringValue];
     NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
     NSError *anError = nil;
    for (CNLabeledValue *label in contact.phoneNumbers) {
        NSString *tmpPhone = [label.value stringValue];
        if ([tmpPhone length] > 0) {
            NBPhoneNumber *myNumber = [phoneUtil parse:tmpPhone defaultRegion:isoCountryCode error:&anError];
            tmpPhone = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164 error:&anError];
            if ([LocalContactsCSV containsString:tmpPhone]) {
                cell.ContactSelectedImageView.image = [UIImage imageNamed: @"camera_record.png"];
                break;
            }
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
    self.Contact =[ContactsArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showContactDetailSegue" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showContactDetailSegue"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        ContactsDetailsViewController *controller = (ContactsDetailsViewController *)navController.topViewController;
        controller.LocalContactsCSV = self.LocalContactsCSV;
        controller.LocalContactsArray = self.LocalContactsArray;
        controller.Contact = self.Contact;
        
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
@end
