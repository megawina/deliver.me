//
//  AIOrderCell.h
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIOrderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *destinAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end
