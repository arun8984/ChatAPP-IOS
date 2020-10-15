//
//  NSObject+ContactSync.h
//  Riot
//
//  Created by Arun on 04/03/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface ContactSync:NSObject
{
    NSString *databasePath;
}

+(ContactSync*)getSharedInstance;
-(BOOL)createDB;
-(void)AddContact:(NSString*)PhoneNumber ContactName:(NSString*)ContactName;
-(NSArray*)GetLocalContacts;
@end
