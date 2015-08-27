//
//  AIOrder.h
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface AIOrder : NSObject

@property (strong, nonatomic) NSArray* senderPointArray;
@property (strong, nonatomic) NSArray* recipientPointArray;

@property (strong, nonatomic) NSString* sender;
@property (strong, nonatomic) NSString* senderPhone;
@property (strong, nonatomic) NSString* recipientPhone;
@property (strong, nonatomic) NSString* status;
@property (strong, nonatomic) NSString* objectId;

@property (strong, nonatomic) NSDate* date;

- (instancetype)initWithObject: (PFObject*) object;

@end
