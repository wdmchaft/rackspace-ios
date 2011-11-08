//
//  LoadBalancersViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancersViewController.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "LoadBalancer.h"
#import "NSObject+Conveniences.h"
#import "UIViewController+Conveniences.h"
#import "LoadBalancerViewController.h"
#import "AddLoadBalancerViewController.h"
#import "APICallback.h"
#import "UIViewController+Conveniences.h"
#import "LoadBalancerProtocol.h"
#import "OpenStackAppDelegate.h"
#import "RootViewController.h"


@implementation LoadBalancersViewController

@synthesize account, tableView;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Load Balancers";
    [self addAddButton];
    
    algorithmNames = [[NSDictionary alloc] initWithObjectsAndKeys:
                      @"Random",@"RANDOM", 
                      @"Round Robin", @"ROUND_ROBIN", 
                      @"Weighted Round Robin", @"WEIGHTED_ROUND_ROBIN", 
                      @"Least Connections", @"LEAST_CONNECTIONS", 
                      @"Weighted Least Connections", @"WEIGHTED_LEAST_CONNECTIONS", 
                      nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!lbsLoaded) {
        [self refreshButtonPressed:nil];
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.account.sortedLoadBalancers count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    LoadBalancer *loadBalancer = [self.account.sortedLoadBalancers objectAtIndex:indexPath.row];
    cell.textLabel.text = loadBalancer.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%i - %@", loadBalancer.protocol.name, loadBalancer.protocol.port, [algorithmNames objectForKey:loadBalancer.algorithm]];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%i - %@", loadBalancer.status, loadBalancer.protocol.port, [algorithmNames objectForKey:loadBalancer.algorithm]];
    cell.imageView.image = [UIImage imageNamed:@"load-balancers-icon.png"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LoadBalancer *loadBalancer = [self.account.sortedLoadBalancers objectAtIndex:indexPath.row];
    LoadBalancerViewController *vc = [[LoadBalancerViewController alloc] initWithLoadBalancer:loadBalancer];
    vc.account = self.account;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self presentPrimaryViewController:vc];
//        if (loaded) {
            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
            if (app.rootViewController.popoverController != nil) {
                [app.rootViewController.popoverController dismissPopoverAnimated:YES];
            }
//        }
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [vc release];
}

#pragma - Button Handlers

- (void)addButtonPressed:(id)sender {
    lbsLoaded = NO; // refresh the list when we come back
    AddLoadBalancerViewController *vc = [[AddLoadBalancerViewController alloc] initWithAccount:self.account];
    [self presentModalViewControllerWithNavigation:vc];
    [vc release];
}

- (IBAction)refreshButtonPressed:(id)sender {
    
    lbsLoaded = YES;
    [self showToolbarActivityMessage:@"Refreshing load balancers..."];
    __block NSInteger refreshCount = 0;
    
    for (NSString *endpoint in [self.account loadBalancerURLs]) {
        [[self.account.manager getLoadBalancers:endpoint] success:^(OpenStackRequest *request) {
            refreshCount++;
            if (refreshCount == [[self.account loadBalancerURLs] count]) {
                [self hideToolbarActivityMessage];
            }
            [self.tableView reloadData];
        } failure:^(OpenStackRequest *request) {
            refreshCount++;
            if (refreshCount == [[self.account loadBalancerURLs] count]) {
                [self hideToolbarActivityMessage];
            }
        }];
    }
    
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    self.tableView = nil;
    self.toolbar = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [account release];
    [tableView release];
    [algorithmNames release];
    [super dealloc];
}


@end

