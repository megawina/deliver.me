//
//  AIPasswordViewController.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//
// **********************************************************************
//
//  Check on server for unique instance
//
// **********************************************************************

#import "AILoginViewController.h"
#import "AISignUpViewController.h"
#import "AIClientViewController.h"
#import "AICourierViewController.h"
#import "AIServerManager.h"

#import "AIUtils.h"

#import <Parse/Parse.h>
#import <LayerKit/LayerKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface AILoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *goButton;

@property (strong, nonatomic) LYRClient* layerClient;

@end

@implementation AILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Login";
    
    self.textLabel.alpha = 0.f;
    self.textLabel.text = (self.userType == AIUserTypeClient) ? @"Enter your phone number" : @"Enter secure password";
    
    self.goButton.enabled = NO;
    self.layerClient = [AIServerManager sharedManager].client;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.phoneField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
}

#pragma mark - Actions

- (IBAction)actionGo:(UIButton *)sender {

    [SVProgressHUD show];
    
    [PFUser
     logInWithUsernameInBackground:self.phoneField.text
     password:self.passwordField.text
     block:^(PFUser *PF_NULLABLE_S user, NSError *PF_NULLABLE_S error) {
         if (!error) {
             [self loginLayer];
         } else {
             [SVProgressHUD dismiss];
             [[[UIAlertView alloc]
              initWithTitle:@"Sorry"
               message:@"It seems you are not registered yet or parameters you enter are invalid. Check it out or sign up first."
              delegate:nil
              cancelButtonTitle:@"Ok"
               otherButtonTitles:nil, nil]
              show];
         }
     }];

}

- (NSString*) stringFrom: (AIUserType) userType {
    
    switch (userType) {
        case AIUserTypeClient:  return @"Client";   break;
        case AIUserTypeCourier: return @"Courier";  break;
        default: break;
    }
}


#pragma mark - Layer Autentification

- (void)loginLayer {

    [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to connect to Layer: %@", error);
        } else {
            PFUser *user = [PFUser currentUser];
            NSString *userID = user.objectId;
            [self authenticateLayerWithUserID:userID completion:^(BOOL success, NSError *error) {
                if (!error){
                    [SVProgressHUD dismiss];
                    [self loadNextScreen];
                } else {
                    NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                }
            }];
        }
    }];
    
}

- (void)authenticateLayerWithUserID:(NSString *)userID completion:(void (^)(BOOL success, NSError * error))completion {
    
    if (self.layerClient.authenticatedUserID) {
        if ([self.layerClient.authenticatedUserID isEqualToString:userID]){
            NSLog(@"Layer Authenticated as User %@", self.layerClient.authenticatedUserID);
            if (completion) {
                completion(YES, nil);
                return;
            }
        } else {
            [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                if (!error){
                    [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
                        if (completion){
                            completion(success, error);
                        }
                    }];
                } else {
                    if (completion){
                        completion(NO, error);
                    }
                }
            }];
        }
    } else {
        [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
            if (completion){
                completion(success, error);
            }
        }];
    }
}

- (void)authenticationTokenWithUserId:(NSString *)userID completion:(void (^)(BOOL success, NSError* error))completion {
    
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (!nonce) {
            if (completion) {
                completion(NO, error);
            }
            return;
        }
        
        NSDictionary *parameters = @{@"nonce" : nonce, @"userID" : userID};
        
        [PFCloud callFunctionInBackground:@"generateToken" withParameters:parameters block:^(id object, NSError *error) {
            if (!error){
                NSString *identityToken = (NSString*)object;
                [self.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                    if (authenticatedUserID) {
                        if (completion) {
                            completion(YES, nil);
                        }
                        NSLog(@"Layer Authenticated as User: %@", authenticatedUserID);
                    } else {
                        completion(NO, error);
                    }
                }];
            } else {
                NSLog(@"Parse Cloud function failed to be called to generate token with error: %@", error);
            }
        }];
        
    }];
}

- (void) loadNextScreen {
    
    AIClientViewController* clientVc =
    [self.storyboard instantiateViewControllerWithIdentifier:@"AIClientViewController"];
    
    AICourierViewController* courierVc =
    [self.storyboard instantiateViewControllerWithIdentifier:@"AICourierViewController"];
    
    UIViewController* vc = (self.userType == AIUserTypeClient) ? clientVc : courierVc;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [UIView
     animateWithDuration:0.5f
     delay:0.f
     options:UIViewAnimationOptionCurveLinear
     animations:^{
         self.textLabel.alpha = 1.0f;
     }
     completion:^(BOOL finished) {
     }];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    self.goButton.enabled = ([self.phoneField.text length] >= 17) ? YES : NO;

    return (textField.tag == 0) ? phoneValidation(textField, range, string) : YES;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    textField.tag == self.phoneField.tag ? [self.passwordField becomeFirstResponder] :
                                            [self actionGo:self.goButton];
    
//    if (textField.tag == self.phoneField.tag) {
//        [textField resignFirstResponder];
//        [self.passwordField becomeFirstResponder];
//    } else {
//        [textField resignFirstResponder];
//        [self actionGo:self.goButton];
//    }
    
    return YES;
}

#pragma mark - AISignUpViewControllerDelegate

- (void) userDidEndSignUp {
    [SVProgressHUD show];
    [self loginLayer];
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"signup"]) {
        AISignUpViewController* vc = segue.destinationViewController;
        vc.delegate = self;
        vc.userType = self.userType;
    }
}

@end
