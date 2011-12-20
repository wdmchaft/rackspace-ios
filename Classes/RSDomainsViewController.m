//
//  RSDomainsViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSDomainsViewController.h"
#import "OpenStackAccount.h"
#import "RSDomain.h"

@implementation RSDomainsViewController

@synthesize account;

- (id)initWithAccount:(OpenStackAccount *)anAccount {
    self = [self initWithNibName:@"RSDomainsViewController" bundle:nil];
    if (self) {
        self.account = anAccount;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Domains";
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table View Data Source and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.account.domains count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellId = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    RSDomain *rsDomain = [[self.account sortedDomains] objectAtIndex:indexPath.row];
    cell.textLabel.text = rsDomain.name;
    cell.detailTextLabel.text = rsDomain.comment;
    
    
    return cell;
}

#pragma mark - Memory Management

- (void)dealloc {
    [account release];
    [super dealloc];
}

@end
