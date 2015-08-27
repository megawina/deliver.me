//
//  ViewController.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/4/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AIStartViewController.h"
#import "AILoginViewController.h"

#import "AIClientViewController.h"
#import "AICourierViewController.h"

#import "AIUtils.h"

#import <Parse/Parse.h>

@interface AIStartViewController ()

@property (assign, nonatomic) AIUserType* userType;

@end

@implementation AIStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - Actions

- (IBAction)actionUserLogin:(UIButton *)sender {
    
    PFUser* user = [PFUser currentUser];
    
    if ([user[@"status"] isEqualToString:@"Client"]) {
        AIClientViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AIClientViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        AILoginViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AIPasswordViewController"];
        vc.userType = AIUserTypeClient;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (IBAction)actionCourierLogin:(UIButton*)sender {
    
    PFUser* user = [PFUser currentUser];
    
    if ([user[@"status"] isEqualToString:@"Courier"]) {
        AICourierViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AICourierViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self goToPasswordWithUserType:AIUserTypeCourier];
    }
    
}

-(void) goToPasswordWithUserType: (AIUserType) userType {
    
    AILoginViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AIPasswordViewController"];
    vc.userType = userType;
    [self.navigationController pushViewController:vc animated:YES];
    
}



@end
