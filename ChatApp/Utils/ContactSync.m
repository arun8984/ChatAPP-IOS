//
//  NSObject+ContactSync.m
//  Riot
//
//  Created by Arun on 04/03/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import "ContactSync.h"
#import <AddressBook/AddressBook.h>
#import "LocalContacts.h"
@implementation ContactSync

static ContactSync *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

+(ContactSync*)getSharedInstance{
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
                    [docsDir stringByAppendingPathComponent: @"contacts.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS contacts (contactid INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, phoneno TEXT NOT NULL UNIQUE,name TEXT NOT NULL)";
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

-(void)AddContact:(NSString*)PhoneNumber ContactName:(NSString*)ContactName{
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL;
        insertSQL = [NSString stringWithFormat:@"insert into contacts (phoneno,name) values(\"%@\",\"%@\")",PhoneNumber, ContactName];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2 (database, insert_stmt,-1, &statement, NULL);
        sqlite3_step(statement);
        /*
        if(sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"Ok");
        }else{
            NSLog(@"NotOk");
        }
         */
        sqlite3_close(database);
    }
}

-(NSArray*)GetLocalContacts{
    
    const char *dbpath = [databasePath UTF8String];
    //sqlite3_reset(statement);
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = @"select contactid,phoneno,name from contacts";
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            ABAddressBookRef UsersAddressBook = ABAddressBookCreateWithOptions(NULL, nil);
            CFArrayRef ContactInfoArray = ABAddressBookCopyArrayOfAllPeople(UsersAddressBook);
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                LocalContacts *localContacts = [LocalContacts new];
                
                localContacts.ContactID =sqlite3_column_int(statement, 0);
                localContacts.PhoneNo = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                localContacts.Name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                
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
                            
                            NSString *searchnumber =localContacts.PhoneNo;
                            //if number matches
                            
                            searchnumber =[[[[[searchnumber stringByReplacingOccurrencesOfString:@"-" withString:@"" ]stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@"+" withString:@""];
                            searchnumber = [searchnumber stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                                                      options:NSRegularExpressionSearch
                                                                                        range:NSMakeRange(0, [searchnumber length])];
                            
                            
                            if([searchnumber rangeOfString:phone].location != NSNotFound)
                            {
                                localContacts.ContactREF =[NSNumber numberWithInt:i];
                                
                            }
                        }
                    }
                    
                }
                
                
                
                [resultArray addObject:localContacts];
                
            }
            return resultArray;
        }
    }
    return nil;
    
}
@end
