//
//  AICalendarViewController.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/6/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AICalendarViewController.h"
#import "AIUtils.h"

@interface AICalendarViewController ()

@property (strong, nonatomic) IBOutlet UIDatePicker* picker;
@property (strong, nonatomic) NSDate* date;

@end

@implementation AICalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Choose date";
    
    self.picker.backgroundColor = [UIColor clearColor];
    [self.picker setValue:COLOR_YELLOW forKey:@"textColor"];
    
}

- (IBAction) saveDate: (UIButton*) sender {
    [self.delegate setDate:self.picker.date];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions

- (IBAction) datePickerValueChanged: (UIDatePicker*) picker {
    [self.delegate setDate:picker.date];
}


@end
