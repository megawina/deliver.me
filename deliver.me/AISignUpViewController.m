//
//  AISignUpViewController.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/10/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AISignUpViewController.h"
#import <Parse/Parse.h>
#import "AIUtils.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface AISignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *signUpFields;

@end

@implementation AISignUpViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UITextField* field in self.signUpFields) {
        [field setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    }
    
}

#pragma mark - Actions

- (IBAction)actionSignUp:(id)sender {
    
    PFUser* user = [PFUser new];
    user.username = self.phoneField.text;
    user.password = self.passwordField.text;
    user.email = self.emailField.text;
    user[@"status"] = [self stringFrom:self.userType];
    
    if (user.username.length != 18 || user.password.length < 4) {
        
        [[[UIAlertView alloc]
         initWithTitle:@"Oops"
         message:@"It seems smth entered incorrect. Phone number or password is wrong. Password must have at least 4 symbols."
         delegate:nil
         cancelButtonTitle:@"Ok"
          otherButtonTitles:nil, nil]
         show];
        
    } else {
        
        [SVProgressHUD show];
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *PF_NULLABLE_S error) {
            
            if (!error) {
                
                [SVProgressHUD dismiss];
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.delegate userDidEndSignUp];
                
            } else {
                
                 [SVProgressHUD dismiss];
                
                [[[UIAlertView alloc]
                 initWithTitle:@"Warning"
                 message:error.localizedDescription
                 delegate:nil
                 cancelButtonTitle:@"Ok"
                  otherButtonTitles:nil, nil]
                 show];
            }
        }];
    }
}

- (IBAction)actionBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods

- (NSString*) stringFrom: (AIUserType) userType {
    
    switch (userType) {
        case AIUserTypeClient:  return @"Client";   break;
        case AIUserTypeCourier: return @"Courier";  break;
        default: break;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return (textField.tag == 0) ? phoneValidation(textField, range, string) : YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSInteger index = textField.tag;
    [textField resignFirstResponder];
    ++index;
    
    if (index < 3) {
        [self.signUpFields[index] becomeFirstResponder];
    }
    return YES;
}

@end
