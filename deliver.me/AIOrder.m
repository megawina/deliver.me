//
//  AIOrder.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AIOrder.h"
#import <Parse/Parse.h>

@implementation AIOrder

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _senderPointArray = [[NSArray alloc] init];
        _recipientPointArray = [[NSArray alloc] init];
    }
    return self;
}

- (instancetype)initWithObject: (PFObject*) object
{
    self = [super init];
    if (self) {
        
        PFUser* user = object[@"sender"];
        self.sender = [user valueForKey:@"objectId"];
        
        self.senderPointArray = [object[@"senderPoint"] firstObject];
        self.recipientPointArray = [object[@"recipientPoint"] firstObject];
        self.senderPhone = object[@"senderPhone"];
        self.recipientPhone = object[@"recipientPhone"];
        self.date = object[@"date"];
        self.status = object[@"status"];
        self.objectId = [object valueForKey:@"objectId"];
        
    }
    return self;
}



@end
