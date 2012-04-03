//
//  RSDomainViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSDomainViewController.h"

/*
 [nav bar: right hand edit to delete domains]
 
 [overview]
 domain name
 domain contact (perhaps allow choose from contacts?)
 
 [domain details]
 nameservers
 ttl > (goes to edit ttl)
 
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
    RSDomainOverviewContactRow
} RSDomainOverviewRowType;

@interface RSDomainViewController ()

@end

@implementation RSDomainViewController

@synthesize tableView, account, domain;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableView = nil;
}

#pragma mark - Table View Data Source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return RSDomainNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - Button Handlers

#pragma mark - Memory Management

- (void)dealloc {
    [tableView release];
    [account release];
    [domain release];
    [super dealloc];
}

@end
