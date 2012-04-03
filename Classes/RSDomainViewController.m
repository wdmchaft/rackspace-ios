//
//  RSDomainViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSDomainViewController.h"

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

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Table View Delegate

#pragma mark - Button Handlers

#pragma mark - Memory Management

- (void)dealloc {
    [tableView release];
    [account release];
    [domain release];
    [super dealloc];
}

@end
