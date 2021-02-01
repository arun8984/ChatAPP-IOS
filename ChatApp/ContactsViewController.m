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

@synthesize FilterContactsArray, ContactsArray, LocalContactsArray, LocalContactsCSV, Contact, mainContactsArray, SyncButton;

-(void)viewDidLoad {
    
    [self removePendingActionMask];
    [self addPendingActionMask];
    
    _searchBarView.showsCancelButton = true;
    _searchBarView.placeholder = @"Search";
    _searchBarView.delegate = self;
    //_searchBarView.returnKeyType = UIReturnKeyDone;
    _searchBarView.autocapitalizationType = UITextAutocapitalizationTypeNone;
   
    [_allContacts setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
    [_goip2callContacts setTitleColor:[UIColor lightGrayColor] forState: UIControlStateNormal];

    [self refreshSearchBarItemsColor:_searchBarView];
    
    [self getAllContacts];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [[self tabBarItem] setTitle:@"Contacts"];

    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Sync"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(SyncContacts:)];

    self.tabBarController.navigationItem.rightBarButtonItem = flipButton;

    [AppDelegate theDelegate].masterTabBarController.navigationItem.title = @"Contacts";

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->tblObj reloadData];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:NO animated:animated]; // Will shows Navigationbar
    [super viewWillDisappear:animated];
    
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

-(void)getAllContacts {

    LocalContactsArray = [[ContactSync getSharedInstance] GetLocalContacts];
    LocalContactsCSV = @"";
   
    for (int j = 0; j < LocalContactsArray.count; j++) {
        LocalContacts *tmpContacts = [LocalContactsArray objectAtIndex:j];
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
            
            self.mainContactsArray = [NSArray arrayWithArray:contacts];
            
            self.ContactsArray = [NSArray arrayWithArray:contacts];
        }
    }];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      NSLog(@"Do some work");
        
        [self removePendingActionMask];
    });
}

-(IBAction)SyncContacts:(id)sender
{
    [self getAllContacts];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (_isAddParticipantSearchBarEditing == YES) {
        
        return [FilterContactsArray count];
    }

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

-(IBAction)allBtnTapped:(UIButton *)sender {
    
    [self addPendingActionMask];

    self.isAddParticipantSearchBarEditing = NO;

    [_allContacts setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
    [_goip2callContacts setTitleColor:[UIColor lightGrayColor] forState: UIControlStateNormal];

    self.ContactsArray = self.mainContactsArray;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      NSLog(@"Do some work");
        
        [self->tblObj reloadData];

        [self removePendingActionMask];
    });
}

-(IBAction)goip2callBtnTapped:(UIButton *)sender {

    [self addPendingActionMask];
    
    self.isAddParticipantSearchBarEditing = NO;

    [_allContacts setTitleColor:[UIColor lightGrayColor] forState: UIControlStateNormal];
    [_goip2callContacts setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];

    NSArray *array = [[NSArray alloc] init];
    NSMutableArray *newArray = [[NSMutableArray alloc] init];

    array = ContactsArray;
    
    if (_isAddParticipantSearchBarEditing == YES) {
        
        array = FilterContactsArray;
    }

    for (int i = 0; i < [array count] ; i++)
    {
        CNContact *contact = [array objectAtIndex:i];

        NSLocale *locale = [NSLocale currentLocale];
        NSString *isoCountryCode = [locale objectForKey: NSLocaleCountryCode];
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        NSError *anError = nil;

        for (CNLabeledValue *label in contact.phoneNumbers) {
           
            NSString *tmpPhone = [label.value stringValue];
          
            if ([tmpPhone length] > 0) {
                
                NBPhoneNumber *myNumber = [phoneUtil parse:tmpPhone defaultRegion:isoCountryCode error:&anError];
                
                tmpPhone = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164 error:&anError];
               
                //NSLog (@"tmpPhone : %@", tmpPhone);
                
                if (tmpPhone != nil) {
                    
                    if ([LocalContactsCSV containsString:tmpPhone]) {

                        [newArray addObject:contact];
                        
                        break;
                    }
                }
            }
        }
    }
    
    ContactsArray = newArray;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      NSLog(@"Do some work");
        
        [self->tblObj reloadData];

        [self removePendingActionMask];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocalContactsTableViewCell *cell = (LocalContactsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
  
    CNContact *contact = nil;

    if (_isAddParticipantSearchBarEditing == YES) {
        
        contact = [FilterContactsArray objectAtIndex:indexPath.row];
    }
    else {
        
        contact = [ContactsArray objectAtIndex:indexPath.row];
    }
        
    cell.backgroundColor = ThemeService.shared.theme.backgroundColor;
    // Configure the cell...
    cell.Name.textColor = ThemeService.shared.theme.textPrimaryColor;
    
    cell.Name.text = [contact.givenName stringByAppendingFormat:@" %@", contact.familyName];
        
    cell.Number.textColor = ThemeService.shared.theme.textSecondaryColor;

    UIImage *image = [UIImage imageWithData:contact.imageData];
    
    if (image == nil) {
        cell.ContactimageView.image = [UIImage imageNamed: @"profilepicture.png"];
    } else {
        cell.ContactimageView.image = [self imageWithImage:image scaledToFillSize:CGSizeMake(50.0f, 50.0f)];
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
           
            //NSLog(@"tmpPhone : %@", tmpPhone);
            
            if (tmpPhone != nil) {
                
                if ([LocalContactsCSV containsString:tmpPhone]) {
                    cell.ContactSelectedImageView.image = [UIImage imageNamed: @"launch_screen_logo.png"];
                    break;
                }
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.Contact = [ContactsArray objectAtIndex:indexPath.row];
    
    if (_isAddParticipantSearchBarEditing == YES) {
        
        self.Contact = [FilterContactsArray objectAtIndex:indexPath.row];
    }

    //self.Contact = [ContactsArray objectAtIndex:indexPath.row];
    
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

#pragma mark - UISearchBar delegate

- (void)refreshSearchBarItemsColor:(UISearchBar *)searchBar
{
    searchBar.delegate = self;
    // bar tint color
    searchBar.barTintColor = searchBar.tintColor = [UIColor whiteColor]; //ThemeService.shared.theme.tintColor;
    searchBar.tintColor = ThemeService.shared.theme.tintColor;
    
    // FIXME: this all seems incredibly fragile and tied to gutwrenching the current UISearchBar internals.

    // text color
    UITextField *searchBarTextField = searchBar.vc_searchTextField;
    searchBarTextField.textColor = ThemeService.shared.theme.textSecondaryColor;
    
    // Magnifying glass icon.
    UIImageView *leftImageView = (UIImageView *)searchBarTextField.leftView;
    leftImageView.image = [leftImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    leftImageView.tintColor = ThemeService.shared.theme.tintColor;
    
    // remove the gray background color
    UIView *effectBackgroundTop =  [searchBarTextField valueForKey:@"_effectBackgroundTop"];
    UIView *effectBackgroundBottom =  [searchBarTextField valueForKey:@"_effectBackgroundBottom"];
    effectBackgroundTop.hidden = YES;
    effectBackgroundBottom.hidden = YES;
        
    // place holder
    if (searchBarTextField.placeholder)
    {
        searchBarTextField.textColor = ThemeService.shared.theme.placeholderTextColor;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.isAddParticipantSearchBarEditing = YES;

    if (FilterContactsArray == nil) {
        
        FilterContactsArray = [[NSMutableArray alloc] init];
    }
    
    [FilterContactsArray removeAllObjects];
        
        NSString *name = @"";
    
        if ([searchText length] > 0)
        {
            for (int i = 0; i < [ContactsArray count] ; i++)
            {
                CNContact *contact = [ContactsArray objectAtIndex:i];

//                name = [contact.givenName stringByAppendingFormat:@" %@", contact.familyName];
                
                name = contact.givenName;

                if (name.length >= searchText.length)
                {
                    NSRange titleResultsRange = [name rangeOfString:searchText options:NSCaseInsensitiveSearch];
                    
                    if (titleResultsRange.length > 0)
                    {
                        [FilterContactsArray addObject:[ContactsArray objectAtIndex:i]];
                    }
                }
            }
        }
        else {
            
            self.isAddParticipantSearchBarEditing = NO;
        }

    [self->tblObj reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.isAddParticipantSearchBarEditing = YES;
    searchBar.showsCancelButton = NO;
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    self.isAddParticipantSearchBarEditing = NO;
        
    // Leave search
    [searchBar resignFirstResponder];
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
