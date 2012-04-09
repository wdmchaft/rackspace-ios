//
//  RSRecordViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, RSDomain, RSRecord;

@interface RSRecordViewController : UITableViewController

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) RSDomain *domain;
@property (nonatomic, retain) RSRecord *record;

- (id)initWithRecord:(RSRecord *)record domain:(RSDomain *)domain account:(OpenStackAccount *)account;

@end
