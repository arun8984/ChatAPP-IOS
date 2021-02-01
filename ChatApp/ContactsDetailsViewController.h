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
#import <MatrixKit/MatrixKit.h>

@interface ContactsDetailsViewController : MXKViewController
{
    IBOutlet UIView *nameContainerView;
    IBOutlet UIView *optionsContainerView;

    IBOutlet UITableView *tblObj;
}

@property (weak, nonatomic) IBOutlet UIImageView *ContactimageView;
@property (weak, nonatomic) IBOutlet UILabel *Name;

@property(nonatomic,strong)CNContact *Contact;
@property(nonatomic,strong)NSString *LocalContactsCSV;
@property(nonatomic,strong)NSArray *LocalContactsArray;

-(IBAction)Call:(UIButton *)sender;
-(IBAction)Chat:(UIButton *)sender;

@end

