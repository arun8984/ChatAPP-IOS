//
//  NSObject+RecentCall.m
//  Cloud Play
//
//  Created by Arun on 19/04/17.
//  Copyright © 2017 Telepixels Solutions Pvt Ltd. All rights reserved.
//

#import "RecentDB.h"
#import "RecentCall.h"
#import <AddressBook/AddressBook.h>

@implementation RecentDB

static RecentDB *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

+(RecentDB*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"recent.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table if not exists recent (callid integer primary key, phoneno text, calltype integer, duration integer, calltime datetime default current_timestamp)";
            sqlite3_prepare_v2 (database, sql_stmt,-1, &statement, NULL);
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"%s Prepare failure '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(database), sqlite3_errcode(database));
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

-(int)AddCall:(NSString*)PhoneNumber CallType:(int)CallType Duration:(int)Duration{
    
    const char *dbpath = [databasePath UTF8String];
    //sqlite3_reset(statement);
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into recent (phoneno,calltype, duration) values(\"%@\",\"%d\", \"%d\")",PhoneNumber, CallType,Duration];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2 (database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            int CallID = (int)sqlite3_last_insert_rowid(database);
            sqlite3_close(database);
            return CallID;
            
        }
        sqlite3_close(database);
    }
    return 0;
}

-(BOOL)UpdateDuration:(int)Duration CallID:(int)CallID{
    
    const char *dbpath = [databasePath UTF8String];
    //sqlite3_reset(statement);
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"update recent set duration = %d where callid = %d",Duration, CallID];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            sqlite3_close(database);
            return YES;
        }
        else {
            sqlite3_close(database);
            return NO;
        }
    }
    
    return NO;
}

-(NSArray*)DeleteRecentsCall:(int)CallID{
    
    const char *dbpath = [databasePath UTF8String];
    NSArray *temp_Call=nil;;
    //sqlite3_reset(statement);
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
       NSString *insertSQL = [NSString stringWithFormat:@"DELETE from recent where callid = %d",CallID];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            temp_Call =[self GetRecentCalls];
            sqlite3_close(database);
            return temp_Call;
           
        }
        else {
            sqlite3_close(database);
            return temp_Call;
        }
    }
    return temp_Call;

}


-(NSArray*)GetRecentCalls{
    
    const char *dbpath = [databasePath UTF8String];
    //sqlite3_reset(statement);
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = @"select callid, phoneno,calltype, duration, calltime from recent order by callid desc limit 0,50";
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            ABAddressBookRef UsersAddressBook = ABAddressBookCreateWithOptions(NULL, nil);
            CFArrayRef ContactInfoArray = ABAddressBookCopyArrayOfAllPeople(UsersAddressBook);
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                RecentCall *recentCall = [RecentCall new];
            
                recentCall.CallID = sqlite3_column_int(statement, 0);
                recentCall.PhoneNo = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                recentCall.CallType = sqlite3_column_int(statement, 2);
                recentCall.Duration = sqlite3_column_int(statement, 3);
                recentCall.CallTime = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                
                sqlite3_close(database);
                if(ContactInfoArray!=nil){
                    //get the total number of count of the users contact
                    CFIndex numberofPeople = CFArrayGetCount(ContactInfoArray);
                    
                    //iterate through each record and add the value in the array
                    for (int i =0; i<numberofPeople; i++) {
                        
                        ABRecordRef ref = CFArrayGetValueAtIndex(ContactInfoArray, i);
                        
                        //Get phone no. from contacts
                        ABMultiValueRef multi = ABRecordCopyValue(ref, kABPersonPhoneProperty);
                        NSString* phone;
                        for (CFIndex j=0; j < ABMultiValueGetCount(multi); j++) {
                            phone=nil;
                            phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(multi, j);
                            phone =[[[[[phone stringByReplacingOccurrencesOfString:@"-" withString:@"" ]stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""];
                            phone = [phone stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                                        options:NSRegularExpressionSearch
                                                                          range:NSMakeRange(0, [phone length])];
                            
                            NSString *searchnumber =recentCall.PhoneNo;
                            //if number matches
                            
                            searchnumber =[[[[[searchnumber stringByReplacingOccurrencesOfString:@"-" withString:@"" ]stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""];
                            searchnumber = [searchnumber stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                                                      options:NSRegularExpressionSearch
                                                                                        range:NSMakeRange(0, [searchnumber length])];
                            
                            
                            if([searchnumber rangeOfString:phone].location != NSNotFound)
                            {
                               recentCall.ContactREF =[NSNumber numberWithInt:i];
                                
                            }
                        }
                    }
                    
                }

                
                
                [resultArray addObject:recentCall];
                
            }
            return resultArray;
        }
    }
    return nil;

}



-(NSString *)GetLastCalledNumber{
    const char *dbpath = [databasePath UTF8String];
    //sqlite3_reset(statement);
    NSString *LastCalledNumber = @"";
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = @"select callid, phoneno,calltype, duration, calltime from recent order by callid desc limit 0,1";
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                LastCalledNumber = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                sqlite3_close(database);
            }
            
        }
    }
    return LastCalledNumber;

}

@end
