//
//  AIConversationListViewController.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/11/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AIConversationListViewController.h"
#import "AIConversationViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import "AIServerManager.h"

@interface AIConversationListViewController () <ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource>

@end

@implementation AIConversationListViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = COLOR_GRAY;
    
    self.delegate = self;
    self.dataSource = self;
    
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelFont:[UIFont fontWithName:@"Helvetica Neue" size:14.f]];
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelColor:COLOR_YELLOW];
    [[ATLConversationTableViewCell appearance] setLastMessageLabelFont:[UIFont fontWithName:@"Helvetica Neue" size:12.f]];
    [[ATLConversationTableViewCell appearance] setLastMessageLabelColor:[UIColor lightGrayColor]];
    [[ATLConversationTableViewCell appearance] setDateLabelFont:[UIFont fontWithName:@"Helvetica Neue" size:12.f]];
    [[ATLConversationTableViewCell appearance] setDateLabelColor:[UIColor lightGrayColor]];
    [[ATLConversationTableViewCell appearance] setUnreadMessageIndicatorBackgroundColor:COLOR_YELLOW];
    [[ATLConversationTableViewCell appearance] setCellBackgroundColor:COLOR_GRAY];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(actionBack:)];
    
}

#pragma mark - Actions

- (void) actionBack: (UIBarButtonItem*) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ATLConversationListViewControllerDelegate

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation {
        
    AIConversationViewController *controller =
    [AIConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    controller.conversation = conversation;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

#pragma mark -  ATLConversationListViewControllerDataSource

- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation {

    NSDictionary* metaData = conversation.metadata;
    NSString* recipientPhone = metaData[@"recipientPhone"];

    return recipientPhone;
}

- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController lastMessageTextForConversation:(LYRConversation *)conversation {

    // check type of last message data and if it text - show it with recipient number else by default
    
    NSDictionary* values = [conversation.lastMessage.parts firstObject];
    
    if ([[values valueForKey:@"MIMEType"] isEqualToString:ATLMIMETypeTextPlain]) {
        
        NSDictionary* metaData = conversation.metadata;
        NSString* senderPhone = metaData[@"senderPhone"];
        
        NSData* lastMessageData = [values valueForKey:@"data"];
        NSString* lastMessageText = [NSString stringWithUTF8String:[lastMessageData bytes]];
        NSString* textToDisplay = [NSString stringWithFormat:@"%@\n%@", senderPhone, lastMessageText];
        
        return textToDisplay;
        
    } else {
        return nil;
    }
    
}


@end
