//
//  UITableViewCell+LocalContactsTableViewCell.m
//  Riot
//
//  Created by Arun on 06/03/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import "LocalContactsTableViewCell.h"

@implementation LocalContactsTableViewCell
@synthesize ContactimageView,Name,Number,ContactSelectedImageView;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
