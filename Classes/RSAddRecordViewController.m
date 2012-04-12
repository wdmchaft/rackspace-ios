//
//  RSAddRecordViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSAddRecordViewController.h"
#import "UIViewController+Conveniences.h"
#import "RSTextFieldCell.h"
#import "RSRecord.h"
#import "AccountManager.h"

typedef enum {
    RSRecordNameRow,
    RSRecordTypeRow,
    RSRecordDataRow,
    RSRecordTTLRow,
    RSRecordMoreInfoRow,
    RSRecordNumberOfRows
} RSRecordRowType;

@interface RSAddRecordViewController ()

@end

@implementation RSAddRecordViewController

@synthesize account, domain, nameTextField, dataTextField, ttlTextField, priorityTextField, recordType;

- (id)initWithAccount:(OpenStackAccount *)anAccount domain:(RSDomain *)aDomain {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.account = anAccount;
        self.domain = aDomain;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add Record";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self addSaveButton];
    
    if (!self.recordType) {
        self.recordType = [[RSRecord recordTypes] objectAtIndex:0];
    }

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RSRecordNumberOfRows;
}

- (Class)cellClassForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == RSRecordTypeRow) {
        return [UITableViewCell class];
    } else {
        return [RSTextFieldCell class];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Class klass = [self cellClassForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(klass)];
    if (cell == nil) {
        cell = [[[klass alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass(klass)] autorelease];
    }
    
    // Configure the cell...
    if ([cell isKindOfClass:[RSTextFieldCell class]]) {
        ((RSTextFieldCell *)cell).textField.delegate = self;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.accessoryType = UITableViewCellAccessoryNone;
        
    switch (indexPath.row) {
        case RSRecordNameRow:
            cell.textLabel.text = @"Name";
            self.nameTextField = ((RSTextFieldCell *)cell).textField;
            break;            
        case RSRecordTypeRow:
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = self.recordType;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;            
        case RSRecordDataRow:
            cell.textLabel.text = @"Data";
            self.dataTextField = ((RSTextFieldCell *)cell).textField;
            break;
        case RSRecordTTLRow:
            cell.textLabel.text = @"TTL (mins)";
            self.ttlTextField = ((RSTextFieldCell *)cell).textField;
            break;
        case RSRecordMoreInfoRow:
            cell.textLabel.text = @"More Info";
            cell.detailTextLabel.text = @"";
            break;            
        default:
            break;
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == RSRecordTypeRow) {
        
        RSRecordTypeViewController *vc = [[RSRecordTypeViewController alloc] initWithDelegate:self];
        vc.selectedRecordType = self.recordType;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        
    }
    
}

#pragma mark - RSRecordTypeViewControllerDelegate

- (void)recordTypeViewController:(RSRecordTypeViewController *)recordTypeViewController didSelectRecordType:(NSString *)type {
    
    self.recordType = type;
    [self.tableView reloadData];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    self.ttlTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.priorityTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    return YES;
    
}

#pragma mark - Button Handlers

- (BOOL)isValid {
    
    return self.nameTextField.text && self.dataTextField.text && self.ttlTextField.text 
        && ![self.nameTextField.text isEqualToString:@""] && ![self.dataTextField.text isEqualToString:@""]
        && ![self.ttlTextField.text isEqualToString:@""];
    
}

- (void)saveButtonPressed:(id)sender {
    
    if (![self isValid]) {
        
        [self alert:@"Error" message:@"Please fill out all fields."];
        
    } else {
        
        RSRecord *record = [[[RSRecord alloc] init] autorelease];
        record.name = self.nameTextField.text;
        record.type = self.recordType;
        record.data = self.dataTextField.text;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        record.ttl = [formatter numberFromString:@"42"];
        [formatter release];        
        
        [[self.account.manager createRecord:record domain:self.domain] success:^(OpenStackRequest *request) {
            
            [self alert:nil message:@"success"];
            
        } failure:^(OpenStackRequest *request) {
            
            [self alert:@"There was a problem creating this record." request:request];
            
        }];
        
    }
    
}

#pragma mark - Memory Management

- (void)dealloc {
    [account release];
    [domain release];
    [nameTextField release];
    [dataTextField release];
    [ttlTextField release];
    [priorityTextField release];
    [super dealloc];
}

@end
