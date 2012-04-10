//
//  RSDomainViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSDomainViewController.h"
#import "RSTextFieldCell.h"
#import "AccountManager.h"
#import "DNSRequest.h"
#import "RSRecord.h"
#import "RSRecordViewController.h"

/*
 [nav bar: right hand edit to delete domains]
 
 [overview]
 domain name
 domain contact (perhaps allow choose from contacts?)
 ttl > (goes to edit ttl)
 
 [domain details]
 nameservers (hold to copy)
 
 [domains]
 blah.overhrd.com - A - 1.1.1.1 > (goes to edit record)
 overhrd.com - NS - dns1.stabletransit.com > (goes to edit record)
 ...
 Add Record
 
 */

typedef enum {
    RSDomainOverviewSection,
    RSDomainDetailsSection,
    RSDomainDomainsSection,
    RSDomainNumberOfSections
} RSDomainSectionType;

typedef enum {
    RSDomainOverviewNameRow,
    RSDomainOverviewContactRow,
    RSDomainOverviewTTLRow
} RSDomainOverviewRowType;

@interface RSDomainViewController ()

@end

@implementation RSDomainViewController

@synthesize account, domain, contactTextField, ttlTextField, isLoading;

#pragma mark - Constructors

- (id)initWithAccount:(OpenStackAccount *)anAccount domain:(RSDomain *)aDomain {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.account = anAccount;
        self.domain = aDomain;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadDomain {
    
    self.isLoading = YES;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(0, 0, 320, 220);
    [spinner startAnimating];
    self.tableView.tableFooterView = spinner;
    
    [[self.account.manager getDomainDetails:self.domain] success:^(OpenStackRequest *request) {
        
        DNSRequest *dnsRequest = (DNSRequest *)request;
        self.domain = [dnsRequest domain];
        self.isLoading = NO;
        self.tableView.tableFooterView = nil;
        [self.tableView reloadData];
        
    } failure:^(OpenStackRequest *request) {
        
        self.isLoading = NO;
        self.tableView.tableFooterView = nil;

    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Domain";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
    [self loadDomain];
    
}

#pragma mark - Table View Data Source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isLoading ? 1 : RSDomainNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case RSDomainOverviewSection:
            return 3;
        case RSDomainDetailsSection:
            return [self.domain.nameservers count];
        default:
            return [self.domain.records count] + 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case RSDomainDetailsSection:
            return @"Nameservers";
        case RSDomainDomainsSection:
            return @"Records";
        default:
            return @"";
    }
}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == RSDomainOverviewSection) {
        return indexPath.row == RSDomainOverviewNameRow ? [UITableViewCell class] : [RSTextFieldCell class];
    } else {
        return [UITableViewCell class];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Class klass = [self cellClassAtIndexPath:indexPath];
    NSString *className = NSStringFromClass(klass);
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:className];
    if (cell == nil) {
        cell = [[klass alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:className];
    }
        
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == RSDomainOverviewSection) {
        
        if (indexPath.row == RSDomainOverviewNameRow) {
            
            cell.textLabel.text = @"Domain Name";
            cell.detailTextLabel.text = self.domain.name;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        } else if (indexPath.row == RSDomainOverviewContactRow) {
            
            RSTextFieldCell *textFieldCell = (RSTextFieldCell *)cell;
            textFieldCell.textLabel.text = @"Contact";
            self.contactTextField = textFieldCell.textField;
            self.contactTextField.delegate = self;
            self.contactTextField.placeholder = @"Email Address";
            self.contactTextField.text = self.domain.emailAddress;
            
        } else if (indexPath.row == RSDomainOverviewTTLRow) {

            RSTextFieldCell *textFieldCell = (RSTextFieldCell *)cell;
            textFieldCell.textLabel.text = @"TTL";
            self.ttlTextField = textFieldCell.textField;
            self.ttlTextField.delegate = self;
            self.ttlTextField.placeholder = @"Time to live (minutes)";
            if (![self.domain.ttl isEqualToString:@"0"]) {
                self.ttlTextField.text = self.domain.ttl;
            }
        }
        
    } else if (indexPath.section == RSDomainDetailsSection) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [self.domain.nameservers objectAtIndex:indexPath.row];
        
    } else if (indexPath.section == RSDomainDomainsSection) {
        
        if (indexPath.row == [self.domain.records count]) {
            
            cell.textLabel.text = @"Add Record";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        } else {

            RSRecord *record = [self.domain.records objectAtIndex:indexPath.row];
            cell.textLabel.text = record.type;
            cell.detailTextLabel.text = record.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
    
    } else {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
    }

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == RSDomainDomainsSection;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.domain.records count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;        
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == RSDomainDomainsSection) {
        
        RSRecord *record = [self.domain.records objectAtIndex:indexPath.row];
        RSRecordViewController *vc = [[RSRecordViewController alloc] initWithRecord:record domain:self.domain account:self.account];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        
    }
    
}

#pragma mark - Text Field Delegate

#pragma mark - Button Handlers

#pragma mark - Memory Management

- (void)dealloc {
    [account release];
    [domain release];
    [contactTextField release];
    [ttlTextField release];
    [super dealloc];
}

@end
