//
//  AINewOrderViewController.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AINewOrderViewController.h"
#import "AICalendarViewController.h"

#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

#import "AIServerManager.h"

#import "AIUtils.h"
#import "AIOrder.h"

typedef enum {
    
    AITextFieldSenderAddress,
    AITextFieldRecipientAddress,
    AITextFieldRecipientPhone
    
} AITextField;

@interface AINewOrderViewController () <UITextFieldDelegate, AICalendarViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutletCollection(UILabel)       NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UITextField)   NSArray *textFields;
@property (strong, nonatomic) IBOutletCollection(UIButton)      NSArray *calendarItems;

@property (weak, nonatomic) IBOutlet UIButton *placeOrderButton;

@property (strong, nonatomic) NSArray* senderPointArray;
@property (strong, nonatomic) NSArray* recipientPointArray;
@property (strong, nonatomic) NSDate*     orderDate;

@property (strong, nonatomic) AICalendarViewController* calendar;
@property (strong, nonatomic) UIActivityIndicatorView* indicator;

@end

@implementation AINewOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"New order";
    
    [self configureStartScreen];
    
    // activ indicator
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:self.placeOrderButton.frame];
    self.indicator.color = COLOR_YELLOW;
    [self.view addSubview:self.indicator];
    
    
}

- (void) configureStartScreen {
    
    for (UILabel* label in self.view.subviews) {
        label.alpha = 1.0f;
    }
    
    for (UITextField* textField in self.textFields) {
        textField.text = @"";
        if (textField.tag != AITextFieldSenderAddress) {
            textField.alpha = 0.15f;
        }
    }
    
    for (UIButton* button in self.calendarItems) {
        [button setTitle:@"" forState:UIControlStateNormal];
        button.alpha = 0.15f;
        button.enabled = NO;
    }
}

#pragma mark - Actions

- (IBAction) actionOpenCalendar: (UIButton*) sender {
    
    self.calendar = [self.storyboard instantiateViewControllerWithIdentifier:@"AICalendarViewController"];
    self.calendar.delegate = self;
    [self.navigationController pushViewController:self.calendar animated:YES];
    
}

- (IBAction)actionPlaceOrder:(UIButton *)sender {
    
    BOOL isInfoCorrect = [self checkInformationToBeCorrent];
    
    if (isInfoCorrect == YES) {
        
        UITextField* phoneTextField = self.textFields[AITextFieldRecipientPhone];
        
        AIOrder* order = [[AIOrder alloc] init];
        
        order.senderPointArray    = [NSArray arrayWithArray:self.senderPointArray];
        order.recipientPointArray = [NSArray arrayWithArray:self.recipientPointArray];
        order.recipientPhone = phoneTextField.text;
        order.date           = self.orderDate;
        order.status         = @"new";
        
        self.placeOrderButton.hidden = YES;
        [self.indicator startAnimating];
        
        [[AIServerManager sharedManager]
         placeNewOrder:order
         onSuccess:^(BOOL success) {
             if (success) {
                 [self showSuccessAlertView];
             }
         }
         onFailure:^(NSError *error) {
             [self showWarningAlertView];
         }];
        
    } else {
        [self showWarningAlertView];
    }
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    for (UIView* view in self.view.subviews) {
        
        [UIView
         animateWithDuration:0.7f
         delay:0.f
         options:UIViewAnimationOptionCurveEaseInOut
         animations:^{
             view.alpha = 0.f;
         }
         completion:^(BOOL finished) {
             [self configureStartScreen];
         }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == AITextFieldRecipientPhone) {
        return phoneValidation(textField, range, string);
    } else {
        return YES;
    }
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    switch (textField.tag) {
            
        case AITextFieldSenderAddress: {
            PFGeoPoint* point = [self getLocationFromAddressString:textField.text];
            self.senderPointArray = @[textField.text, point];
        }
            break;
            
        case AITextFieldRecipientAddress: {
            PFGeoPoint* point = [self getLocationFromAddressString:textField.text];
            self.recipientPointArray = @[textField.text, point];
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    NSInteger index = textField.tag;
    
    if (index < AITextFieldRecipientPhone) {
        index++;
        [self.textFields[index] becomeFirstResponder];
        
        UITextField* textf = self.textFields[textField.tag + 1];
        [self makeAlphaAnimationFor:textf];
        
    } else {
        
        for (UIButton* button in self.calendarItems) {
            button.enabled = YES;
            [self makeAlphaAnimationFor:button];
            
        }
    }
    
    return YES;
}

- (BOOL) checkInformationToBeCorrent {
    
    UITextField* phoneTextField = self.textFields[AITextFieldRecipientPhone];
    
    PFGeoPoint* p1 = [self.senderPointArray lastObject];
    PFGeoPoint* p2 = [self.recipientPointArray lastObject];
    
    if (p1.latitude != 0 && p1.longitude != 0 &&
        p2.latitude != 0 && p2.longitude != 0 &&
        phoneTextField.text.length == 18 && self.orderDate) {
        
        return YES;
    } else {
        return NO;
    }
    
}


#pragma mark - Map

- (PFGeoPoint*) getLocationFromAddressString: (NSString*) addressStr {
    
    double latitude = 0, longitude = 0;
    
    NSString *esc_addr  = [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req       = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result    = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    
    if (result) {
        
        NSScanner *scanner = [NSScanner scannerWithString:result];
        
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    
    PFGeoPoint* center = [PFGeoPoint geoPoint];
    center.latitude=latitude;
    center.longitude = longitude;
    
    return center;
    
}

#pragma mark - AICalendarViewControllerDelegate

-(void)setDate:(NSDate *)date {
    self.orderDate = date;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@" MM/dd hh:mm a"];
    NSString* dateString = [formatter stringFromDate:self.orderDate];
    
    [[self.calendarItems lastObject] setTitle:dateString forState:UIControlStateNormal];
    
}

#pragma mark - Alerts, Animations

- (void) makeAlphaAnimationFor: (UIView*) view {
    
    [UIView
     animateWithDuration:0.7f
     delay:0.f
     options:UIViewAnimationOptionCurveEaseOut
     animations:^{
         view.alpha = 1.0f;
     }
     completion:^(BOOL finished) {
         
     }];
}

- (void) showWarningAlertView {
    
    [[[UIAlertView alloc]
      initWithTitle:@"Sorry"
      message:@"Something goes wrong. Try again."
      delegate:nil
      cancelButtonTitle:@"Cancel"
      otherButtonTitles:nil, nil]
     show];
    
}

- (void) showSuccessAlertView {
    
    self.placeOrderButton.hidden = NO;
    [self.indicator stopAnimating];
    
    [[[UIAlertView alloc]
      initWithTitle:@"Success!"
      message:@"Order has been placed. Wait for notification about operations on it."
      delegate:self
      cancelButtonTitle:@"Cancel"
      otherButtonTitles:@"New order", nil]
     show];
    
}


@end
