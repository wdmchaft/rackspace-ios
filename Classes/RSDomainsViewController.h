//
//  RSDomainsViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount;

@interface RSDomainsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) OpenStackAccount *account;

- (id)initWithAccount:(OpenStackAccount *)account;

@end
