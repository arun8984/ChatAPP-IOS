//
//  NSObject+LocalContactsViewController.h
//  Riot
//
//  Created by Arun on 06/03/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "MXSession+Riot.h"

@interface LocalContactsViewController:UITableViewController
{
    ABAddressBookRef UsersAddressBook;
    CFArrayRef ContactInfoArray;
    NSArray *AllPhoneNos;
    int LIMIT;
    int TotalPages, CurrentPage;
    UIActivityIndicatorView *pendingMaskSpinnerView;
}

@property(nonatomic,retain)NSArray *ContactsArray;
@property(nonatomic,retain)NSMutableArray *SelectedContacts;
@property(nonatomic,retain)NSString *Username;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *StartChatButton;
@property(nonatomic, retain)MXSession *mainSession;

-(IBAction)CancelButtonClicked:(id)sender;
-(IBAction)StartChatButtonClicked:(id)sender;

@end
