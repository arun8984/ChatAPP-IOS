//
//  UIViewController+InCallController.h
//  Cloud Play
//
//  Created by Arun on 19/04/17.
//  Copyright © 2017 Telepixels Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Riot-Swift.h"
#import "RecentDB.h"
#import <AVFoundation/AVFoundation.h>
#include "call.h"
@interface InCallController:UIViewController
{
    bool muted,isSpeaker,isBluetooth,isDialpadVisibile;
    
    NSTimer *timer;
    NSString *PhoneNo;
    AppDelegate *appDelegate;
    RecentDB *recentDB;
    int CallID;
    int CallDuration;    
}
@property (strong, nonatomic) IBOutlet UIImageView *ContactimageView;
@property (strong, nonatomic) IBOutlet UILabel *callStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *lblNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblDuration;
@property (strong, nonatomic) IBOutlet UIButton *btnEndCall;
@property (strong, nonatomic) IBOutlet UIButton *btnSpeaker;
@property (strong, nonatomic) IBOutlet UIButton *btnMic;
@property (strong, nonatomic) IBOutlet UIButton *btnBluetooth;
@property (strong, nonatomic) IBOutlet UIButton *btnInEndCall;
@property (strong, nonatomic) IBOutlet UIButton *btnInAnswerCall;
@property (strong, nonatomic) IBOutlet UIButton *btnShowHideDialPad;
@property (strong, nonatomic) IBOutlet UIView *DialPadView;
@property (strong, nonatomic) IBOutlet UILabel *lblDialPadNumber;

-(void)CheckCallStatus;
-(void)DisconnectCall;
-(IBAction)EndCall:(id)sender;
-(IBAction)SpeakerCall:(id)sender;
-(IBAction)MuteCall:(id)sender;
-(IBAction)AnswerCall:(id)sender;
-(IBAction)BluetoothCall:(id)sender;

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
-(IBAction)ShowHideDialPad:(id)sender;

@end
