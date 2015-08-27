//
//  AIClientViewController.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AIClientViewController.h"
#import "AIOrdersTableViewController.h"
#import "AIServerManager.h"

#import <Parse/Parse.h>
@import MessageUI;

@interface AIClientViewController () <MFMailComposeViewControllerDelegate>
@end

@implementation AIClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Profile";
    
    UIBarButtonItem* exitItem = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Exit"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(actionExit:)];
    
    self.navigationItem.leftBarButtonItems = @[exitItem];
    
    self.layerClient = [AIServerManager sharedManager].client;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Actions

- (IBAction) actionSendMessage:(id) sender {
    
    NSString *emailTitle = @"Hi. I want to report about deliver.me";
    NSArray *toRecipents = [NSArray arrayWithObject:@"megawina@live.ru"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setToRecipients:toRecipents];
    
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) actionExit: (UIBarButtonItem*) item {
    
    [PFUser logOutInBackground];
    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        if (!error) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            NSLog(@"deatentificate");
        } else {
            NSLog(@"deauthenticateWithCompletion %@", error.localizedDescription);
        }
    }];
    
    
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
 
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    AIOrdersTableViewController* vc = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"showClientHistoryIdentifier"]) {
        vc.ordersToDisplay = AIOrdersToDisplayClientHistory;
    }
}


@end
