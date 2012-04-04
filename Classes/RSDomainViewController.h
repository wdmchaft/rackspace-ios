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

@interface RSDomainViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) RSDomain *domain;

@property (nonatomic, retain) UITextField *contactTextField;
@property (nonatomic, retain) UITextField *ttlTextField;

- (id)initWithAccount:(OpenStackAccount *)account domain:(RSDomain *)domain;

@end
