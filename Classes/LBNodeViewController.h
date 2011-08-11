//
//  LBNodeViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadBalancer, LoadBalancerNode, OpenStackAccount, LoadBalancerViewController;

@interface LBNodeViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
    @private
    NSArray *spinners;
    BOOL editable;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, retain) LoadBalancerNode *node;
@property (nonatomic, assign) LoadBalancerViewController *lbViewController;
@property (nonatomic, retain) NSIndexPath *lbIndexPath;

- (id)initWithNode:(LoadBalancerNode *)node loadBalancer:(LoadBalancer *)loadBalancer account:(OpenStackAccount *)account;

@end
