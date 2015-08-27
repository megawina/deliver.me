//
//  AIListTableViewController.m
//  deliver.me
//
//  Created by Anton Ivashyna on 8/5/15.
//  Copyright (c) 2015 Anton Ivashyna. All rights reserved.
//

#import "AIOrdersTableViewController.h"
#import "AIConversationListViewController.h"
#import "AIConversationViewController.h"

#import "AIServerManager.h"
#import <Parse/Parse.h>
#import <LayerKit/LayerKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "AIOrder.h"
#import "AIOrderCell.h"

@interface AIOrdersTableViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray* allOrders;        // all orders from request
@property (strong, nonatomic) NSMutableArray* courierOrders;    // current courier orders with 'in process' status

@property (strong, nonatomic) AIOrder* selectedOrder;
@property (strong, nonatomic) NSIndexPath* selectedCellIndexPath;
@property (strong, nonatomic) NSDateFormatter* formatter;

@end

@implementation AIOrdersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allOrders = [NSMutableArray array];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = @"Orders";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl
     addTarget:self
     action:@selector(refreshData)
     forControlEvents:UIControlEventValueChanged];
    
    UIImage* chatImage = [UIImage imageNamed:@"chat.png"];
    UIButton* chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [chatButton setImage:chatImage forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(actionOpenConversationList:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    self.navigationItem.rightBarButtonItem = item;
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MMM/dd HH:mm a"];
    
    [self getOrdersToDisplay:self.ordersToDisplay withRefresh:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Actions

- (void) actionOpenConversationList: (UIButton*) sender {
    
    LYRClient* client = [AIServerManager sharedManager].client;
    AIConversationListViewController* vc = [AIConversationListViewController
                                            conversationListViewControllerWithLayerClient:client];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - Data Methods

- (void) refreshData {
    [self getOrdersToDisplay:self.ordersToDisplay withRefresh:YES];
}

- (void) getOrdersToDisplay: (AIOrdersToDisplay) ordersToDisplay withRefresh:(BOOL) refresh {
    
    [SVProgressHUD show];
    
    [[AIServerManager sharedManager]
     getOrdersWithType:self.ordersToDisplay
     onSuccess:^(NSArray* array) {
         
         [self.allOrders removeAllObjects];
         [self.allOrders addObjectsFromArray:array];
         
         NSSortDescriptor* statusDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"status" ascending:YES];
         [self.allOrders sortUsingDescriptors:@[statusDescriptor]];
         
         if (refresh == YES) {
             [self.refreshControl endRefreshing];
             [self.tableView reloadData];
             [SVProgressHUD dismiss];
         } else {
             [self.allOrders count] == 0 ? [self showEmptyLabel] : [self insertRowsInTableView];
             [SVProgressHUD dismiss];
         }
         
     }
     onFailure:^(NSError* error) {
         if (error) {
             [[[UIAlertView alloc]
               initWithTitle:@"Trouble"
               message:error.localizedDescription
               delegate:nil
               cancelButtonTitle:@"Ok"
               otherButtonTitles:nil, nil]
              show];
         }
     }];
}

- (void) saveNewOrderStatus: (NSString*) status {
    
    [[AIServerManager sharedManager]
     setNewStatus:status
     toOrder:self.selectedOrder
     onSuccess:^(BOOL success) {
         if (success) {
             [self refreshData];
         }
         
     }
     onFailure:nil];
}

- (void) insertRowsInTableView {
    
    NSMutableArray* indexPaths = [NSMutableArray array];
    for (int i = 0; i < self.allOrders.count; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
}

- (void) showEmptyLabel {
    
    UILabel* label = [[UILabel alloc] initWithFrame:self.view.bounds];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    
    label.textColor = COLOR_YELLOW;
    label.font      = [UIFont fontWithName:@"Helvetica Neue" size:14.f];
    label.alpha     = 0.f;
    
    label.text = @"There are no orders to display.\n\nYou have to create it first :)";
    [self.view addSubview:label];
    
    [UIView
     animateWithDuration:0.7f
     delay:0.f
     options:UIViewAnimationOptionCurveEaseInOut
     animations:^{
         label.alpha = 1.0f;
     }
     completion:nil];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allOrders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"orderCelIdentifier";
    
    AIOrderCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[AIOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell: (AIOrderCell*) cell atIndexPath: (NSIndexPath*) indexPath {
    
    AIOrder* order = self.allOrders[indexPath.row];
    
    cell.statusImageView.hidden = (self.ordersToDisplay != AIOrdersToDisplayCourierCurrent) ? YES : NO;
    cell.statusImageView.image = ([order.status isEqualToString:@"new"]) ? [UIImage imageNamed:@"circle_green.png"] : [UIImage imageNamed:@"circle_yellow.png"];
    
    cell.destinAddressLabel.text = [order.recipientPointArray firstObject];     // first object - name of place, last object - PFGeoPoint
    cell.senderAddressLabel.text = [order.senderPointArray firstObject];
    
    NSString* dateString = [self.formatter stringFromDate:order.date];
    
    cell.dateLabel.text = dateString;
    
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedOrder = self.allOrders[indexPath.row];
    self.selectedCellIndexPath = indexPath;
    
    if ([self.selectedOrder.status isEqualToString:@"in process"]) {
        
        NSString* message = [NSString
                             stringWithFormat:@"Accept order delivery? \nfrom %@ \nto %@",
                             self.selectedOrder.senderPhone,
                             self.selectedOrder.recipientPhone];
        
        [[[UIAlertView alloc]
          initWithTitle:@"So quick?"
          message:message
          delegate:self
          cancelButtonTitle:@"Cancel"
          otherButtonTitles:@"Accept", @"Send message", @"Decline order", nil]
         show];
        
        NSLog(@"accept");
        
    } else if ([self.selectedOrder.status isEqualToString:@"new"]) {
        
        [[[UIAlertView alloc]
          initWithTitle:@"Do you want to get new order?"
          message:@"Click 'YES' to continue"
          delegate:self
          cancelButtonTitle:@"Cancel"
          otherButtonTitles:@"Yes", nil]
         show];
    }
    
    
    NSLog(@"\n %@ \n %@", self.selectedOrder.sender, [PFUser currentUser].objectId);
    
        
}

#pragma mark - Alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 1: [self makeOrderDoneForAlertView:alertView]; break;
        case 2: [self createConversationWithOrderSender]; break;
        case 3: [self saveNewOrderStatus:@"new"]; break;
        default: break;
    }
}

- (void) makeOrderDoneForAlertView: (UIAlertView*) alertView {
    
    if ([alertView.title isEqualToString:@"So quick?"]) {
        
        [self.allOrders removeObject:self.selectedOrder];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[self.selectedCellIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        [self saveNewOrderStatus:@"done"];
        
    } else {
        [self saveNewOrderStatus:@"in process"];
    }
}

#pragma mark - Conversation

- (void) createConversationWithOrderSender {
    
    NSDictionary* metaData = @{@"senderPhone" : self.selectedOrder.senderPhone,
                               @"recipientPhone" : self.selectedOrder.recipientPhone};
    
    LYRClient* client = [AIServerManager sharedManager].client;
    AIConversationViewController* vc = [AIConversationViewController conversationViewControllerWithLayerClient:client];
    NSError* error = nil;
    
    NSSet* participants = [NSSet setWithArray:@[self.selectedOrder.sender, [PFUser currentUser].objectId]];
    
    LYRConversation* conversation = [client
                                     newConversationWithParticipants:[NSSet set]
                                     options:@{LYRConversationOptionsDistinctByParticipantsKey : @YES}
                                     error:&error];
    [conversation addParticipants:participants error:nil];
    
    [conversation setValuesForMetadataKeyPathsWithDictionary:metaData merge:YES];
    vc.conversation = conversation;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
