//
//  AIConcersationViewController.h
//  deliver.me
//
//  Created by Anton Ivashyna on 8/10/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "ATLConversationViewController.h"

#import <Atlas/Atlas.h>
#import <Parse/Parse.h>
#import <LayerKit/LayerKit.h>

@interface AIConversationViewController : ATLConversationViewController <ATLConversationViewControllerDataSource,
                                                                            ATLConversationViewControllerDelegate>

@end
