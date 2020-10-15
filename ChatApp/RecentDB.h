//
//  NSObject+RecentCall.h
//  Cloud Play
//
//  Created by Arun on 19/04/17.
//  Copyright © 2017 Telepixels Solutions Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface RecentDB:NSObject
{
    NSString *databasePath;
}

+(RecentDB*)getSharedInstance;

-(BOOL)createDB;

-(int)AddCall:(NSString*)PhoneNumber CallType:(int)CallType Duration:(int)Duration;

-(BOOL)UpdateDuration:(int)Duration CallID:(int)CallID;

-(NSArray*)DeleteRecentsCall:(int)CallID;
    
-(NSArray*)GetRecentCalls;

-(NSString *)GetLastCalledNumber;

@end


