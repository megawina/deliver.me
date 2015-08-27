//
//  AIServerManager.h
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIUtils.h"

#import <Parse/Parse.h>
#import <LayerKit/LayerKit.h>

@class Parse, AIOrder;

@interface AIServerManager : NSObject

@property (strong, nonatomic) LYRClient* client;

+ (AIServerManager*) sharedManager;

#pragma mark - Parse

- (void) placeNewOrder: (AIOrder*) order
             onSuccess:(void(^)(BOOL success)) success
             onFailure:(void(^)(NSError* error)) failure;

- (void) getOrdersWithType:(AIOrdersToDisplay) type
                 onSuccess:(void(^)(NSArray* array)) success
                 onFailure:(void(^)(NSError* error)) failure;

- (void) setNewStatus: (NSString*) status
              toOrder: (AIOrder*) order
            onSuccess:(void(^)(BOOL success)) success
            onFailure:(void(^)(NSError* error)) failure;

#pragma mark - Layer

- (void) queryAndCacheUsersWithIDs:(NSArray*)userIDs
                        completion: (void(^)(NSArray* participants, NSError* error))completion;

- (PFUser*) cachedUserForUserID:(NSString*) userID;
- (void) cacheUserIfNeeded:(PFUser*) user;
- (NSArray*) unCachedUserIDsFromParticipants:(NSArray*) participants;
- (NSArray*) resolvedNamesFromParticipants:(NSArray*) participants;

@end
