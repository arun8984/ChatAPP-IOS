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

#import <UIKit/UIKit.h>
#import <Contacts/CNContactStore.h>
#import <Contacts/CNContactFetchRequest.h>
#import "MXSession+Riot.h"

@interface ContactsViewController : UIViewController <UISearchBarDelegate>
{
    IBOutlet UITableView *tblObj;
    UIActivityIndicatorView *pendingMaskSpinnerView;
}

@property (weak, nonatomic) IBOutlet UIButton *allContacts;
@property (weak, nonatomic) IBOutlet UIButton *goip2callContacts;

@property(nonatomic,retain)NSArray *mainContactsArray;
@property(nonatomic,retain)NSArray *LocalContactsArray;
@property(nonatomic,retain)NSString *LocalContactsCSV;
@property(nonatomic,retain)NSArray *ContactsArray;
@property(nonatomic,retain)CNContact *Contact;
@property(nonatomic,retain)NSMutableArray *FilterContactsArray;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarView;
@property (nonatomic) BOOL isAddParticipantSearchBarEditing;

@property(nonatomic,retain) IBOutlet UIBarButtonItem *SyncButton;

@end

