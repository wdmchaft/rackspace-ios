//
//  RSAddDomainViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount;

@interface RSAddDomainViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) UITextField *domainNameTextField;
@property (nonatomic, retain) UITextField *emailTextField;
@property (nonatomic, retain) UITextField *ttlTextField;

- (id)initWithAccount:(OpenStackAccount *)account;

@end
