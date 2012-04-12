//
//  RSAddRecordViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenStackAccount.h"
#import "RSRecordTypeViewController.h"
#import "RSDomain.h"

@interface RSAddRecordViewController : UITableViewController <RSRecordTypeViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) RSDomain *domain;
@property (nonatomic, retain) UITextField *nameTextField;
@property (nonatomic, retain) UITextField *dataTextField;
@property (nonatomic, retain) UITextField *ttlTextField;
@property (nonatomic, retain) UITextField *priorityTextField;
@property (nonatomic, retain) NSString *recordType;

- (id)initWithAccount:(OpenStackAccount *)account domain:(RSDomain *)domain;

@end
