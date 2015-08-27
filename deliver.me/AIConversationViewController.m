//
//  AIConcersationViewController.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/10/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AIConversationViewController.h"

#import "AIUtils.h"

#import "AIServerManager.h"
#import "PFUser+ATLParticipant.h"

@interface AIConversationViewController ()

@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation AIConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = COLOR_GRAY;
    
    self.delegate = self;
    self.dataSource = self;
    
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextFont:[UIFont fontWithName:@"Helvetica Neue" size:14.f]];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageTextFont:[UIFont fontWithName:@"Helvetica Neue" size:14.f]];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
}

#pragma mark - ATLConversationViewControllerDelegate

- (void)conversationViewController:(ATLConversationViewController *)viewController didSendMessage:(LYRMessage *)message {
    NSLog(@"didSendMessage");
}

#pragma mark - ATLConversationViewControllerDataSource

- (id<ATLParticipant>)conversationViewController:(ATLConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier {
    
    NSLog(@"participantIdentifier - %@", participantIdentifier);
    
    if ([participantIdentifier isEqualToString:[PFUser currentUser].objectId]) {
        return [PFUser currentUser];
    }
    
    PFUser* user = [[AIServerManager sharedManager] cachedUserForUserID:participantIdentifier];
    if (!user) {
        [[AIServerManager sharedManager]
         queryAndCacheUsersWithIDs:@[participantIdentifier]
         completion:^(NSArray *participants, NSError *error) {
             if (participants && error == nil) {
                 [self.addressBarController reloadView];
                 [self reloadCellsForMessagesSentByParticipantWithIdentifier:participantIdentifier];
             } else {
                 NSLog(@"Error querying for users: %@", error);
             }
         }];
    }
    
    return nil;
    
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date {
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor grayColor] };
    return [[NSAttributedString alloc] initWithString:[self.dateFormatter stringFromDate:date] attributes:attributes];
    
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus {
    
    NSLog(@"recipientStatus - %@", [recipientStatus allKeys]);
    
    if (recipientStatus.count == 0) return nil;
    NSMutableAttributedString *mergedStatuses = [[NSMutableAttributedString alloc] init];
    
    [[recipientStatus allKeys] enumerateObjectsUsingBlock:^(NSString *participant, NSUInteger idx, BOOL *stop) {
        LYRRecipientStatus status = [recipientStatus[participant] unsignedIntegerValue];
        if ([participant isEqualToString:self.layerClient.authenticatedUserID]) {
            return;
        }
        
        NSString *checkmark = @"✔︎";
        
        UIColor *textColor = [UIColor greenColor];
        if (status == LYRRecipientStatusSent) {
            textColor = [UIColor lightGrayColor];
        } else if (status == LYRRecipientStatusDelivered) {
            textColor = [UIColor orangeColor];
        } else if (status == LYRRecipientStatusRead) {
            textColor = [UIColor greenColor];
        }
        NSAttributedString *statusString = [[NSAttributedString alloc] initWithString:checkmark attributes:@{NSForegroundColorAttributeName: textColor}];
        [mergedStatuses appendAttributedString:statusString];
    }];
    return mergedStatuses;
    
    return nil;
    
}


@end
