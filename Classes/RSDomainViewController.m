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

@synthesize account, domain, contactTextField, ttlTextField;

#pragma mark - Constructors

- (id)initWithAccount:(OpenStackAccount *)anAccount domain:(RSDomain *)aDomain {
    self = [self initWithNibName:@"RSDomainViewController" bundle:nil];
    if (self) {
        self.account = anAccount;
        self.domain = aDomain;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Domain";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[self.account.manager getDomainDetails:self.domain] success:^(OpenStackRequest *request) {
        
    } failure:^(OpenStackRequest *request) {
    
    }];
    
}

#pragma mark - Table View Data Source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return RSDomainNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case RSDomainOverviewSection:
            return 3;
        case RSDomainDetailsSection:
            return 3;
        default:
            return 1;
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
            self.ttlTextField.text = self.domain.ttl;
            
        }
        
    } else {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
    }

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == RSDomainDomainsSection;
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
