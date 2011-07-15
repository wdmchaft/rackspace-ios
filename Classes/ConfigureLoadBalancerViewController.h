//
//  ConfigureLoadBalancerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer, VirtualIP;

@interface ConfigureLoadBalancerViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
@private
    NSDictionary *algorithmNames;
    VirtualIP *selectedVirtualIP;
    NSIndexPath *selectedVIPIndexPath;
    UIActionSheet *deleteActionSheet;
    UIActionSheet *ipActionSheet;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer;

@end
