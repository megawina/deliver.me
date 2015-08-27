//
//  AISignUpViewController.h
//  deliver.me
//
//  Created by Anton Ivashyna on 8/10/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIUtils.h"

@protocol AISignUpViewControllerDelegate;

@interface AISignUpViewController : UIViewController

@property (weak, nonatomic) id <AISignUpViewControllerDelegate> delegate;
@property (assign, nonatomic) AIUserType userType;

@end

@protocol AISignUpViewControllerDelegate <NSObject>

- (void) userDidEndSignUp;

@end
