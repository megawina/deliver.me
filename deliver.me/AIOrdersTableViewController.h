//
//  AIListTableViewController.h
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIUtils.h"

#import <UIKit/UIKit.h>
#import <Atlas/Atlas.h>
#import <ParseUI.h>

@class AIOrderCell;

@interface AIOrdersTableViewController : UITableViewController

@property (assign, nonatomic) AIOrdersToDisplay ordersToDisplay;

@end
