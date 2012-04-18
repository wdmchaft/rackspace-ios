//
//  RSRecordViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSAddRecordViewController.h"

@class OpenStackAccount, RSDomain, RSRecord;

@interface RSRecordViewController : RSAddRecordViewController // UITableViewController

@property (nonatomic, retain) RSRecord *record;

- (id)initWithRecord:(RSRecord *)record domain:(RSDomain *)domain account:(OpenStackAccount *)account;

@end
