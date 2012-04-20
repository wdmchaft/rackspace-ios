//
//  RSIPAddressesViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, RSIPAddressesViewController, Server;

@protocol RSIPAddressesViewControllerDelegate <NSObject>

- (void)ipAddressesViewController:(RSIPAddressesViewController *)viewController didSelectIPAddress:(NSString *)ipAddress;

@end

@interface RSIPAddressesViewController : UITableViewController

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) NSMutableArray *ipAddresses;
@property (nonatomic, assign) id<RSIPAddressesViewControllerDelegate> delegate;

- (id)initWithDelegate:(id)aDelegate account:(OpenStackAccount *)anAccount;

@end
