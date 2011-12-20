//
//  RSDomainsViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenStackViewController.h"

@class OpenStackAccount;

@interface RSDomainsViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) OpenStackAccount *account;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (id)initWithAccount:(OpenStackAccount *)account;
- (IBAction)refreshButtonPressed:(id)sender;

@end
