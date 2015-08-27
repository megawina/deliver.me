//
//  PFUser+ATLParticipant.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/11/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "PFUser+ATLParticipant.h"

@implementation PFUser (ATLParticipant)

@dynamic avatarImageURL;

- (NSString *)firstName {
    return self.username;
}

- (NSString *)lastName {
    return @"";
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.username, self.lastName];
}

- (NSString *)participantIdentifier {
    return self.objectId;
}

- (UIImage *)avatarImage {
    return nil;
}

- (NSString *)avatarInitials {
    return [[NSString stringWithFormat:@"%@%@", [self.firstName substringToIndex:1], [self.lastName substringToIndex:1]] uppercaseString];
}

@end
