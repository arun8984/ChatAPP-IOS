//
//  NSObject+LocalContacts.h
//  Riot
//
//  Created by Arun on 05/03/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalContacts:NSObject
@property (readwrite, nonatomic) int ContactID;
@property (strong, nonatomic) NSString *PhoneNo;
@property (strong, nonatomic) NSString *Name;
@property (strong, nonatomic)NSNumber *ContactREF;
@end
