//
//  AICourierViewController.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AICourierViewController.h"
#import "AIOrdersTableViewController.h"

@interface AICourierViewController ()

@end

@implementation AICourierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Profile";
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    AIOrdersTableViewController* vc = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"showCourierHistoryIdentifier"]) {
        vc.ordersToDisplay = AIOrdersToDisplayCourierHistory;
    } else if ([segue.identifier isEqualToString:@"showCurrentOrdersIdentifier"]) {
        vc.ordersToDisplay = AIOrdersToDisplayCourierCurrent;
    }
}

@end
