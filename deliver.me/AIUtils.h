//
//  AIUtils.h
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - DEFINE 

#define COLOR_GRAY   [UIColor colorWithRed:56/255.f green:63/255.f blue:74/255.f alpha:1]
#define COLOR_YELLOW [UIColor colorWithRed:255/255.f green:207/255.f blue:70/255.f alpha:1]

#pragma mark - ENUMS

typedef enum {
    
    AIUserTypeClient,
    AIUserTypeCourier
    
} AIUserType ;


typedef enum {
    
    AIOrdersToDisplayClientHistory,
    AIOrdersToDisplayCourierHistory,
    AIOrdersToDisplayCourierCurrent
    
} AIOrdersToDisplay;

#pragma mark - METHODS

BOOL phoneValidation (UITextField* textField, NSRange range, NSString* string);