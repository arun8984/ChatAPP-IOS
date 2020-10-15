//
//  UIViewController+RecentController.h
//  Cloud Play
//
//  Created by Arun on 18/04/17.
//  Copyright © 2017 Telepixels Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface RecentController:UITableViewController
{
    ABAddressBookRef UsersAddressBook;
    CFArrayRef ContactInfoArray;
}
@property(nonatomic,retain)NSArray *CDRData;
@property(nonatomic,retain)NSMutableArray *recent_CDRData;
@end
