//
//  RSRecordViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSRecordViewController.h"
#import "RSRecord.h"
#import "UIViewController+Conveniences.h"
#import "AccountManager.h"

@implementation RSRecordViewController

@synthesize account, domain, record;

- (id)initWithRecord:(RSRecord *)aRecord domain:(RSDomain *)aDomain account:(OpenStackAccount *)anAccount {
    
    self = [super initWithAccount:anAccount domain:aDomain];
    if (self) {
        self.record = aRecord;
    }
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"Record";
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    [super tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    self.nameTextField.text = self.record.name;
    self.nameTextField.enabled = NO;
    self.dataTextField.text = self.record.data;
    self.ttlTextField.text = [self.record.ttl description];
    self.priorityTextField.text = self.record.priority;
    
}

- (void)saveButtonPressed:(id)sender {
    
    if (![super isValid]) {
        
        [self alert:@"Error" message:@"Please fill out all fields."];
        
    } else {
        
        self.record.type = self.recordType;
        self.record.data = self.dataTextField.text;
        
        if (self.priorityTextField.text && ![self.priorityTextField.text isEqualToString:@""]) {
            self.record.priority = self.priorityTextField.text;
        }
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        self.record.ttl = [formatter numberFromString:self.ttlTextField.text];
        [formatter release];        
        
        [[self.account.manager updateRecord:record domain:self.domain] success:^(OpenStackRequest *request) {
                        
        } failure:^(OpenStackRequest *request) {
            
            [self alert:@"There was a problem creating this record." request:request];
            
        }];
        
    }
    
}

- (void)dealloc {
    [record release];
    [super dealloc];
}

@end
