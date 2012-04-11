//
//  RSAddRecordViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenStackAccount.h"

@interface RSAddRecordViewController : UITableViewController

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *typeTextField;
@property (nonatomic, retain) IBOutlet UITextField *dataTextField;


//RSRecordNameRow,
//RSRecordTypeRow,
//RSRecordDataRow,
//RSRecordMoreInfoRow,


- (id)initWithAccount:(OpenStackAccount *)account;

@end
