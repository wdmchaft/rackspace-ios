//
//  ConfigureLoadBalancerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer, VirtualIP, LoadBalancerViewController;

@interface ConfigureLoadBalancerViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
@private
    NSDictionary *algorithmNames;
    VirtualIP *selectedVirtualIP;
    UIActionSheet *deleteActionSheet;
    UIActionSheet *ipActionSheet;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, retain) LoadBalancerViewController *loadBalancerViewController;
@property (nonatomic, retain) NSIndexPath *selectedVIPIndexPath;

- (id)initWithAccount:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer;

@end
