//
//  RSDomainViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OpenStackViewController.h"
#import "RSDomain.h"
#import "OpenStackAccount.h"

@interface RSDomainViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) RSDomain *domain;

- (id)initWithAccount:(OpenStackAccount *)account domain:(RSDomain *)domain;

@end
