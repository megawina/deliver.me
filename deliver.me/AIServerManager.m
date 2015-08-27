//
//  AIServerManager.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AIServerManager.h"

#import "AIOrder.h"

@interface AIServerManager ()

@property (strong, nonatomic) NSCache* userCache;

@end

@implementation AIServerManager

+ (AIServerManager*) sharedManager {
    
    static AIServerManager* manager = nil;
    
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[AIServerManager alloc] init];
        });
    }
    
    return manager;
}

#pragma mark - Parse.com

- (void) placeNewOrder: (AIOrder*) order
             onSuccess:(void(^)(BOOL success)) success
             onFailure:(void(^)(NSError* error)) failure {
    
    PFObject* newOrder = [PFObject objectWithClassName:@"Orders"];
    
    PFUser* user = [PFUser currentUser];
    
    [newOrder setObject:user forKey:@"sender"];
    
    [newOrder addUniqueObject:order.senderPointArray     forKey:@"senderPoint"];
    [newOrder addUniqueObject:order.recipientPointArray  forKey:@"recipientPoint"];
    
    [newOrder setValue:order.recipientPhone forKey:@"recipientPhone"];
    [newOrder setValue:order.date           forKey:@"date"];
    [newOrder setValue:order.status         forKey:@"status"];
    [newOrder setValue:user.username        forKey:@"senderPhone"];
    
    [newOrder
     saveInBackgroundWithBlock:^(BOOL succeeded, NSError *PF_NULLABLE_S error) {
         
         if (succeeded) {
             success (YES);
             
             [[PFUser currentUser] addUniqueObject:newOrder forKey:@"orders"];
             [[PFUser currentUser] saveInBackgroundWithBlock:nil];
             
         }
         
         if (error) {
             failure (error);
         }
         
     }];
}

- (void) getOrdersWithType:(AIOrdersToDisplay) type
                 onSuccess:(void(^)(NSArray* array)) success
                 onFailure:(void(^)(NSError* error)) failure {
    
    NSPredicate* predicate;
    
    switch (type) {
            
        case AIOrdersToDisplayClientHistory:
            predicate = [NSPredicate predicateWithFormat:@"sender = %@ AND status = %@", [PFUser currentUser], @"done"];
            break;
            
        case AIOrdersToDisplayCourierHistory:
            predicate = [NSPredicate predicateWithFormat:@"status = %@", @"done"];
            break;
            
        case AIOrdersToDisplayCourierCurrent:
            predicate = [NSPredicate predicateWithFormat:@"status = %@ OR status = %@", @"new", @"in process"];
            break;
            
        default:
            break;
    }
    
    PFQuery* query = [PFQuery queryWithClassName:@"Orders" predicate:predicate];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *PF_NULLABLE_S objects, NSError *PF_NULLABLE_S error) {
        
        NSMutableArray* orders = [NSMutableArray array];
        
        for (PFObject* object in objects) {
            AIOrder* order = [[AIOrder alloc] initWithObject:object];
            [orders addObject:order];
        }
        
        if (objects) {
            success(orders);
        }
        if (error) {
            failure(error);
        }
        
    }];
    
}

- (void) setNewStatus: (NSString*) status
              toOrder: (AIOrder*) order
            onSuccess:(void(^)(BOOL success)) success
            onFailure:(void(^)(NSError* error)) failure {
    
    PFQuery* query = [PFQuery queryWithClassName:@"Orders"];
    [query
     getObjectInBackgroundWithId:order.objectId
     block:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error) {
         
         [object setObject:[PFUser currentUser] forKey:@"courier"];
         [object setValue:status forKey:@"status"];
         [object saveInBackground];
         success(YES);
         
     }];
}

#pragma mark - Cache

- (void) queryAndCacheUsersWithIDs:(NSArray *)userIDs
                        completion:(void (^)(NSArray *, NSError *))completion {
    
    PFQuery* query = [PFUser query];
    [query whereKey:@"objectId" containedIn:userIDs];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *PF_NULLABLE_S objects, NSError *PF_NULLABLE_S error) {
        
        if (!error) {
            for (PFUser* user in objects) {
                [self cacheUserIfNeeded:user];
            }
            if (completion) [objects count] > 0 ? completion(objects, nil) : completion(nil, nil);
        } else {
            if (completion) completion(nil, nil);
        }
    }];
}

- (PFUser*) cachedUserForUserID:(NSString*) userID {
    
    if ([self.userCache objectForKey:userID]) {
        return [self.userCache objectForKey:userID];
    }
    return nil;
    
}

- (void) cacheUserIfNeeded:(PFUser*) user {
    
    if (![self.userCache objectForKey:user.objectId]) {
        [self.userCache setObject:user forKey:user.objectId];
    }
    
}

- (NSArray *)unCachedUserIDsFromParticipants:(NSArray *)participants {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *userID in participants) {
        if ([userID isEqualToString:[PFUser currentUser].objectId]) continue;
        if (![self.userCache objectForKey:userID]) {
            [array addObject:userID];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

- (NSArray *)resolvedNamesFromParticipants:(NSArray *)participants {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *userID in participants) {
        if ([userID isEqualToString:[PFUser currentUser].objectId]) continue;
        if ([self.userCache objectForKey:userID]) {
            PFUser *user = [self.userCache objectForKey:userID];
            [array addObject:user.username];
        }
    }
    return [NSArray arrayWithArray:array];
}

@end
