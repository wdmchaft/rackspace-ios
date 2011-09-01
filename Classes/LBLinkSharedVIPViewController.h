//
//  LBLinkSharedVIPViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer, VirtualIP;

@interface LBLinkSharedVIPViewController : UITableViewController {
    VirtualIP *selectedVirtualIP;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer;

@end
