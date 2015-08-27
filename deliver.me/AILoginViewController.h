//
//  AIPasswordViewController.h
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIUtils.h"

#import "AISignUpViewController.h"

@interface AILoginViewController : UIViewController <AISignUpViewControllerDelegate>

@property (assign, nonatomic) AIUserType userType;

@end
