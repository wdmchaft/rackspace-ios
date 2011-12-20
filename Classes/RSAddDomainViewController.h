//
//  RSAddDomainViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount;

@interface RSAddDomainViewController : UITableViewController

@property (nonatomic, strong) OpenStackAccount *account;

- (id)initWithAccount:(OpenStackAccount *)account;

@end
