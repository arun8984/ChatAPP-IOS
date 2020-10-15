//
//  UIViewController+KeypadController.h
//  Cloud Play
//
//  Created by Arun on 17/04/17.
//  Copyright © 2017 Telepixels Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ContactsUI/ContactsUI.h>
#import <AddressBookUI/AddressBookUI.h>

@interface KeypadController: UIViewController<UITextFieldDelegate,ABPeoplePickerNavigationControllerDelegate, CNContactPickerDelegate,CNContactViewControllerDelegate>{
    NSTimer *timer;
}

@property(nonatomic,retain) IBOutlet UITextField *txtPhoneNo;
@property(nonatomic,retain) IBOutlet UILabel *lblStatus;
@property(nonatomic,retain) IBOutlet UILabel *lblBalance;
@property(nonatomic,retain) IBOutlet UIButton *btndel;
@property(nonatomic,retain) IBOutlet UIButton *btn0;

-(IBAction)KeyPress0:(id)sender;
-(IBAction)KeyPress1:(id)sender;
-(IBAction)KeyPress2:(id)sender;
-(IBAction)KeyPress3:(id)sender;
-(IBAction)KeyPress4:(id)sender;
-(IBAction)KeyPress5:(id)sender;
-(IBAction)KeyPress6:(id)sender;
-(IBAction)KeyPress7:(id)sender;
-(IBAction)KeyPress8:(id)sender;
-(IBAction)KeyPress9:(id)sender;
-(IBAction)KeyPressStar:(id)sender;
-(IBAction)KeyPressPound:(id)sender;
-(IBAction)KeyPressContact:(id)sender;
-(IBAction)KeyPressCall:(id)sender;
-(IBAction)KeyPressDel:(id)sender;

@end
