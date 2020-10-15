//
//  UITableViewCell+LocalContactsTableViewCell.h
//  Riot
//
//  Created by Arun on 06/03/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalContactsTableViewCell:UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ContactimageView;
@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Number;
@property (weak, nonatomic) IBOutlet UIImageView *ContactSelectedImageView;
@end
