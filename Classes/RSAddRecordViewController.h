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

@interface RSAddRecordViewController : UITableViewController <RSRecordTypeViewControllerDelegate>

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) IBOutlet UITextField *nameTextField;
@property (nonatomic, retain) IBOutlet UITextField *typeTextField;
@property (nonatomic, retain) IBOutlet UITextField *dataTextField;

@property (nonatomic, retain) NSString *recordType;

//RSRecordNameRow,
//RSRecordTypeRow,
//RSRecordDataRow,
//RSRecordMoreInfoRow,


- (id)initWithAccount:(OpenStackAccount *)account;

@end
