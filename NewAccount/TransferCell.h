//
//  TransferCell.h
//  Riot
//
//  Created by Arun on 05/04/18.
//  Copyright © 2018 matrix.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransferCell: UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Amount;
@property (weak, nonatomic) IBOutlet UILabel *time;
@end
