//
//  UIViewController+InCallController.m
//  Cloud Play
//
//  Created by Arun on 19/04/17.
//  Copyright © 2017 Telepixels Solutions Pvt Ltd. All rights reserved.
//

#import "InCallController.h"
#import "Riot-Swift.h"
#import <AddressBook/AddressBook.h>

@implementation InCallController

@synthesize lblNumber,lblDuration,callStatusLabel,ContactimageView,btnEndCall,btnSpeaker,btnMic,btnBluetooth,btnInEndCall,btnInAnswerCall,btnShowHideDialPad,DialPadView,lblDialPadNumber;

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    muted=NO;
    isSpeaker = NO;
    isBluetooth = NO;
    isDialpadVisibile = NO;
    [DialPadView setHidden:YES];
    [lblDialPadNumber setText:@""];
    CallDuration = 0;
    
    recentDB = [RecentDB getSharedInstance];
    
    NSString *address = [AppDelegate theDelegate].CalledNo;
    
    self.view.backgroundColor = ThemeService.shared.theme.backgroundColor;
    
    if([AppDelegate theDelegate].isIncoming){
        pjsua_call_info callInfo;
        pjsua_call_get_info([AppDelegate theDelegate].call_id, &callInfo);
        NSString *remoteinfo =  [NSString stringWithFormat:@"%s", callInfo.remote_info.ptr];
        NSArray *arrRemote = [remoteinfo componentsSeparatedByString:@"<"];
        address = [[[[[arrRemote objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""]stringByReplacingOccurrencesOfString:@"-" withString:@""]stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        //address =  [call GetCallerID];
        CallID = [recentDB AddCall:address CallType:1 Duration:0];
        
        [btnEndCall setHidden:YES];
        [btnMic setHidden:YES];
        [btnSpeaker setHidden:YES];
        [btnBluetooth setHidden:YES];
        [lblDuration setHidden:YES];
        [btnInAnswerCall setHidden:NO];
        [btnInEndCall setHidden:NO];
        
    }else{
        if([address isEqualToString:@"onnet950msg"]){
            CallID = 0;
        }else{
            CallID = [recentDB AddCall:address CallType:0 Duration:0];
        }
        
        [btnEndCall setHidden:NO];
        [btnMic setHidden:NO];
        [btnSpeaker setHidden:NO];
        [btnBluetooth setHidden:NO];
        [lblDuration setHidden:NO];
        
        [btnInAnswerCall setHidden:YES];
        [btnInEndCall setHidden:YES];
    }
    
    [btnSpeaker setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f] forState:UIControlStateNormal];
    [btnMic setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f] forState:UIControlStateNormal];
    [btnBluetooth setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f] forState:UIControlStateNormal];
    
    if([address isEqualToString:@"onnet950msg"]){
        [lblNumber setText:[NSString stringWithFormat:@"%@",@"Voicemail"]];
    }else{
        [lblNumber setText:[NSString stringWithFormat:@"%@",address]];
    }
    
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (granted){
            
            
            ABAddressBookRef UsersAddressBook = ABAddressBookCreateWithOptions(NULL, nil);
            
            //contains details for all the contacts
            CFArrayRef ContactInfoArray = ABAddressBookCopyArrayOfAllPeople(UsersAddressBook);
            
            if(ContactInfoArray!=nil){
                //get the total number of count of the users contact
                CFIndex numberofPeople = CFArrayGetCount(ContactInfoArray);
                
                //iterate through each record and add the value in the array
                for (int i =0; i<numberofPeople; i++) {
                    
                    ABRecordRef ref = CFArrayGetValueAtIndex(ContactInfoArray, i);
                    
                    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
                    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
                    if (lastName !=nil) {
                        firstName = [firstName stringByAppendingFormat:@" %@",lastName];
                    }
                    
                    //Get phone no. from contacts
                    ABMultiValueRef multi = ABRecordCopyValue(ref, kABPersonPhoneProperty);
                    UIImage *iimage;
                    
                    
                    //if person has image store it
                    if (ABPersonHasImageData(ref)) {
                        
                        CFDataRef imageData=ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
                        iimage = [UIImage imageWithData:(__bridge NSData *)imageData];
                        
                    }
                    
                    
                    
                    
                    
                    NSString* phone;
                    for (CFIndex j=0; j < ABMultiValueGetCount(multi); j++) {
                        
                        phone=nil;
                        phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(multi, j);
                        phone =[[[[[phone stringByReplacingOccurrencesOfString:@"-" withString:@"" ]stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""];
                        phone = [phone stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                                    options:NSRegularExpressionSearch
                                                                      range:NSMakeRange(0, [phone length])];
                        
                        NSString *searchnumber =address;
                        
                        searchnumber =[[[[[searchnumber stringByReplacingOccurrencesOfString:@"-" withString:@"" ]stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""];
                        searchnumber = [searchnumber stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                                                  options:NSRegularExpressionSearch
                                                                                    range:NSMakeRange(0, [searchnumber length])];
                        
                        //if number matches
                        if([searchnumber rangeOfString:phone].location != NSNotFound)
                        {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.lblNumber setText:firstName];
                                //set image and name
                                if (iimage!=nil)
                                    self.ContactimageView.image=iimage;
                                
                            });
                            
                            
                        }
                        
                        
                    }
                }
                
            }
            
            
            
        }});
    
    
    
    
    
    
    callStatusLabel.text=@"Calling";
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(CheckCallStatus) userInfo:nil repeats:YES];
}

-(IBAction)AnswerCall:(id)sender{
    pjsua_call_id callid =[AppDelegate theDelegate].call_id;
    sip_answer(&callid);
    [btnEndCall setHidden:NO];
    [btnMic setHidden:NO];
    [btnSpeaker setHidden:NO];
    [btnBluetooth setHidden:NO];
    [lblDuration setHidden:NO];
    
    [btnInAnswerCall setHidden:YES];
    [btnInEndCall setHidden:YES];
}

-(IBAction)EndCall:(id)sender{
    [self DisconnectCall];
}
-(IBAction)BluetoothCall:(id)sender{
    
    isBluetooth=!isBluetooth;
    
    
    if (isBluetooth) {
        pjmedia_aud_dev_route route = PJMEDIA_AUD_DEV_ROUTE_BLUETOOTH;
        pjsua_snd_set_setting(PJMEDIA_AUD_DEV_CAP_INPUT_ROUTE, &route, PJ_FALSE);
        [btnBluetooth setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
    }else{
        pjmedia_aud_dev_route route = PJMEDIA_AUD_DEV_ROUTE_DEFAULT;
        pjsua_snd_set_setting(PJMEDIA_AUD_DEV_CAP_INPUT_ROUTE, &route, PJ_TRUE);
        [btnBluetooth setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f] forState:UIControlStateNormal];
        
    }
}

-(IBAction)SpeakerCall:(id)sender{
    
    isSpeaker=!isSpeaker;
    
    
     if (isSpeaker) {
     pjmedia_aud_dev_route route = PJMEDIA_AUD_DEV_ROUTE_DEFAULT;
     pjsua_snd_set_setting(PJMEDIA_AUD_DEV_CAP_INPUT_ROUTE, &route, PJ_FALSE);
     }else{
     pjmedia_aud_dev_route route = PJMEDIA_AUD_DEV_ROUTE_LOUDSPEAKER;
     pjsua_snd_set_setting(PJMEDIA_AUD_DEV_CAP_INPUT_ROUTE, &route, PJ_FALSE);
     }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError* error;
    
    
    if (isSpeaker) {
        
        
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        [btnSpeaker setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
    }else{
        
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        [btnSpeaker setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f] forState:UIControlStateNormal];
        
        
    }
    
    
}
-(IBAction)MuteCall:(id)sender{
    muted = !muted;
    
    if (muted)
        pjsua_conf_adjust_rx_level(0 /* pjsua_conf_port_id slot*/, 0.0f);
    else
        pjsua_conf_adjust_rx_level(0 /* pjsua_conf_port_id slot*/, 1.0f);
    
    
    if (muted) {
        
        [btnMic setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
    }else{
        
        [btnMic setTitleColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f] forState:UIControlStateNormal];
        
    }
    
}

-(void)DisconnectCall{
    
    //[appDelegate.endpoint disableAudio];
    pjsua_call_id callid =[AppDelegate theDelegate].call_id;
    sip_hangup(&callid);
    [recentDB UpdateDuration:CallDuration CallID:CallID];
    [timer invalidate];
    timer=nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self performSegueWithIdentifier:@"ShowTab" sender:self];
    //[self.view removeFromSuperview];
    
}
- (void)sendDigits:(NSString *)digits {
    
    pj_str_t dtmf = pj_str((char *)[digits UTF8String]);
    pj_status_t status = pjsua_call_dial_dtmf([AppDelegate theDelegate].call_id, &dtmf);
}
-(IBAction)KeyPress0:(id)sender{
    
    [self sendDigits:@"0"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"0"];
    AudioServicesPlaySystemSound(1200);
}
-(IBAction)KeyPress1:(id)sender{
    
    [self sendDigits:@"1"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"1"];
    AudioServicesPlaySystemSound(1201);
}
-(IBAction)KeyPress2:(id)sender{
    
    [self sendDigits:@"2"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"2"];
    AudioServicesPlaySystemSound(1202);
}
-(IBAction)KeyPress3:(id)sender{
    
    [self sendDigits:@"3"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"3"];
    AudioServicesPlaySystemSound(1203);
}
-(IBAction)KeyPress4:(id)sender{
    
    [self sendDigits:@"4"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"4"];
    AudioServicesPlaySystemSound(1204);
}
-(IBAction)KeyPress5:(id)sender{
    
    [self sendDigits:@"5"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"5"];
    AudioServicesPlaySystemSound(1205);
}
-(IBAction)KeyPress6:(id)sender{
    
    [self sendDigits:@"6"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"6"];
    AudioServicesPlaySystemSound(1206);
}
-(IBAction)KeyPress7:(id)sender{
    
    [self sendDigits:@"7"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"7"];
    AudioServicesPlaySystemSound(1207);
}
-(IBAction)KeyPress8:(id)sender{
    
    [self sendDigits:@"8"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"8"];
    AudioServicesPlaySystemSound(1208);
}
-(IBAction)KeyPress9:(id)sender{
    
    [self sendDigits:@"9"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"9"];
    AudioServicesPlaySystemSound(1209);
}
-(IBAction)KeyPressStar:(id)sender{
    
    [self sendDigits:@"*"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"*"];
    AudioServicesPlaySystemSound(1210);
}
-(IBAction)KeyPressPound:(id)sender{
    
    [self sendDigits:@"#"];
    lblDialPadNumber.text = [lblDialPadNumber.text stringByAppendingString:@"#"];
    AudioServicesPlaySystemSound(1211);
}
-(IBAction)ShowHideDialPad:(id)sender{
    
    isDialpadVisibile=!isDialpadVisibile;
    
    if (isDialpadVisibile) {
        [DialPadView setHidden:NO];
        [lblDialPadNumber setText:@""];
        [ContactimageView setHidden:YES];
        [btnShowHideDialPad setImage:[UIImage imageNamed:@"HideDialPad.png"] forState:UIControlStateNormal];
    }else{
        [DialPadView setHidden:YES];
        [ContactimageView setHidden:NO];
        [btnShowHideDialPad setImage:[UIImage imageNamed:@"ShowDialPad.png"] forState:UIControlStateNormal];
    }
}

-(NSString *)FormatDuration:(int)duration{
    BOOL hasHours = duration / 3600 > 0;
    if (hasHours) {
        return [NSString stringWithFormat:@"%d:%02d:%02d", duration/3600, (duration % 3600)/60, duration % 60];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d", duration/60, duration % 60];
    }
}
-(void)CheckCallStatus{
    
    pjsua_call_info call;
    pjsua_call_get_info([AppDelegate theDelegate].call_id, &call);
    
    
    
    if (call.state == PJSIP_INV_STATE_CONFIRMED) {
        
        CallDuration = [[NSNumber  numberWithLong:call.connect_duration.sec] intValue];
        callStatusLabel.text = @"Connected";
        lblDuration.text =[self FormatDuration:CallDuration];
    }
    if (call.state == PJSIP_INV_STATE_CALLING) {
        callStatusLabel.text = @"Calling";
    }
    if (call.state == PJSIP_INV_STATE_CONNECTING || call.state == PJSIP_INV_STATE_EARLY ) {
        callStatusLabel.text = @"Connecting";
    }
    if (call.state == PJSIP_INV_STATE_DISCONNECTED || call.state == PJSIP_INV_STATE_NULL ) {
        [self DisconnectCall];
    }
    
}


@end
