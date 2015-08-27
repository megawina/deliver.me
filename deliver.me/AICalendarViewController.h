//
//  AICalendarViewController.h
//  deliver.me
//
//  Created by Anton Ivashyna on 8/6/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AICalendarViewControllerDelegate;

@interface AICalendarViewController : UIViewController

@property (weak, nonatomic) id <AICalendarViewControllerDelegate> delegate;

@end


@protocol AICalendarViewControllerDelegate <NSObject>

- (void) setDate: (NSDate*) date;

@end