//
//  ContainersViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackViewController.h"

@class OpenStackAccount;

@interface ContainersViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    OpenStackAccount *account;    
    IBOutlet UIBarButtonItem *refreshButton;
    BOOL containersLoaded;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) OpenStackAccount *account;

- (void)refreshButtonPressed:(id)sender;

@end
