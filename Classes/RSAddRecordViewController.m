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
#import "RSIPAddressesViewController.h"

typedef enum {
    RSRecordNameRow,
    RSRecordTypeRow,
    RSRecordDataRow,
    RSRecordTTLRow,
    RSRecordPriorityRow,
    RSRecordNumberOfRows
} RSRecordRowType;

@interface RSAddRecordViewController ()

@end

@implementation RSAddRecordViewController

@synthesize account, domain, nameTextField, dataTextField, ttlTextField, priorityTextField, recordType, dataToolbar;

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

- (BOOL)recordTypeHasPriority {
    return [self.recordType isEqualToString:@"MX"] || [self.recordType isEqualToString:@"SRV"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self recordTypeHasPriority] ? RSRecordNumberOfRows : RSRecordNumberOfRows - 1;
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
        case RSRecordPriorityRow:
            cell.textLabel.text = @"Priority";
            self.priorityTextField = ((RSTextFieldCell *)cell).textField;
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

- (void)configureToolbar {
    
    if (!self.dataToolbar) {
    
        CGRect start = CGRectMake(0, 460, 320, 44);
        CGRect end = CGRectMake(0, 156, 320, 44);
        
        self.dataToolbar = [[UIToolbar alloc] initWithFrame:start];
        self.dataToolbar.barStyle = UIBarStyleBlack;
        self.dataToolbar.translucent = YES;
        
        UIBarButtonItem *ipButton = [[UIBarButtonItem alloc] initWithTitle:@"Cloud Server IPs" style:UIBarButtonItemStyleBordered target:self action:@selector(ipButtonPressed:)];
        UIBarButtonItem *domainButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@", self.domain.name] style:UIBarButtonItemStyleBordered target:self action:@selector(domainButtonPressed:)];
        UIBarButtonItem	*flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
        
        self.dataToolbar.items = [NSArray arrayWithObjects:ipButton, domainButton, flexibleSpace, doneButton, nil];
        
        [self.tableView addSubview:self.dataToolbar];
        
        [UIView animateWithDuration:0.35 animations:^{
            
            self.dataToolbar.frame = end;
            self.tableView.scrollEnabled = NO;
            
        }];
        
    }
    
}

- (void)hideDataToolbar {
    
    CGRect start = CGRectMake(0, 460, 320, 44);
    
    [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
        
        self.dataToolbar.frame = start;
        self.tableView.scrollEnabled = YES;
        
    } completion:^(BOOL finished) {
        
        [self.dataToolbar removeFromSuperview];
        self.dataToolbar = nil;
        
    }];

}

- (void)doneButtonPressed:(id)sender {
    
    [self.dataTextField resignFirstResponder];
    [self hideDataToolbar];
    
}

- (void)ipButtonPressed:(id)sender {
    
    RSIPAddressesViewController *vc = [[RSIPAddressesViewController alloc] initWithDelegate:self account:self.account];
    [self presentModalViewControllerWithNavigation:vc];
    [vc release];
    
}

- (void)domainButtonPressed:(id)sender {
    
    NSString *string = [NSString stringWithFormat:@"%@%@", self.dataTextField.text, self.domain.name];
    self.dataTextField.text = string;
    [self.dataTextField resignFirstResponder];
    [self hideDataToolbar];
    
}

- (void)ipAddressesViewController:(RSIPAddressesViewController *)viewController didSelectIPAddress:(NSString *)ipAddress {
    
    self.dataTextField.text = ipAddress;
    [self.dataTextField resignFirstResponder];
    [self hideDataToolbar];    
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    self.ttlTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.priorityTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    if ([textField isEqual:self.dataTextField]) {
        
        // show the toolbar for the data text field
        [self configureToolbar];
        
    }
             
    
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];

    if (![textField.text isEqualToString:@""]) {

        if ([textField isEqual:self.nameTextField]) {
            [self.dataTextField becomeFirstResponder];
        } else if ([textField isEqual:self.dataTextField]) {
            [self.ttlTextField becomeFirstResponder];
        } else if ([textField isEqual:self.ttlTextField]) {
            if ([self recordTypeHasPriority]) {
                [self.priorityTextField becomeFirstResponder];
            }
        }
        
    }
    
    return NO;
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
        
        if (self.priorityTextField.text && ![self.priorityTextField.text isEqualToString:@""]) {
            record.priority = self.priorityTextField.text;
        }
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        record.ttl = [formatter numberFromString:self.ttlTextField.text];
        [formatter release];        
        
        [[self.account.manager createRecord:record domain:self.domain] success:^(OpenStackRequest *request) {
            
            [self alert:@"Your record has been submitted." request:request];
            
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
    [dataToolbar release];
    [super dealloc];
}

@end
