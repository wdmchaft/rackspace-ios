//
//  LBNodeViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadBalancer, LoadBalancerNode, OpenStackAccount;

@interface LBNodeViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
    LoadBalancerNode *node;
    @private
    NSArray *spinners;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, retain) LoadBalancerNode *node;

- (id)initWithNode:(LoadBalancerNode *)node loadBalancer:(LoadBalancer *)loadBalancer account:(OpenStackAccount *)account;

@end
