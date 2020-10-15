//
//  NSObject_RecentCall.h
//  Cloud Play
//
//  Created by Arun on 19/04/17.
//  Copyright © 2017 Telepixels Solutions Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentCall : NSObject

@property (readwrite, nonatomic) int CallID;
@property (strong, nonatomic) NSString *PhoneNo;
@property (readwrite, nonatomic) int CallType;
@property (readwrite, nonatomic) int Duration;
@property (strong, nonatomic) NSString *CallTime;
@property (strong, nonatomic)NSNumber *ContactREF;

@end
