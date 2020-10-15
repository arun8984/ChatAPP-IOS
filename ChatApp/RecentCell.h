//
//  RecentCell.h
//  Pixee
//
//  Created by Arun on 22/01/16.
//  Copyright © 2016 Telepixels Solutions Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ContactimageView;
@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Number;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *Duration;
@property (weak, nonatomic) IBOutlet UIImageView *CallTypeimageView;
@end
