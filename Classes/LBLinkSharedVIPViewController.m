//
//  LBLinkSharedVIPViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBLinkSharedVIPViewController.h"
#import "OpenStackAccount.h"
#import "LoadBalancer.h"
#import "LoadBalancerProtocol.h"
#import "VirtualIP.h"


@implementation LBLinkSharedVIPViewController

@synthesize account, loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)a loadBalancer:(LoadBalancer *)lb {
    self = [super initWithNibName:@"LBLinkSharedVIPViewController" bundle:nil];
    if (self) {
        self.account = a;
        self.loadBalancer = lb;
    }
    return self;
}

- (void)dealloc {
    [account release];
    [loadBalancer release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Link Load Balancers";
    self.loadBalancer.virtualIPs = [NSMutableArray array];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *endpoint = [self.account loadBalancerEndpointForRegion:self.loadBalancer.region];
    return [[self.account.loadBalancers objectForKey:endpoint] count];
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSString *endpoint = [self.account loadBalancerEndpointForRegion:self.loadBalancer.region];
    LoadBalancer *lb = [[[self.account.loadBalancers objectForKey:endpoint] allValues] objectAtIndex:indexPath.row];
    VirtualIP *vip = [lb.virtualIPs objectAtIndex:0];
    
    cell.textLabel.text = lb.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@:%i", vip.address, lb.protocol.name, lb.protocol.port];
    cell.imageView.image = [UIImage imageNamed:@"load-balancers-icon.png"];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *endpoint = [self.account loadBalancerEndpointForRegion:self.loadBalancer.region];
    LoadBalancer *lb = [[[self.account.loadBalancers objectForKey:endpoint] allValues] objectAtIndex:indexPath.row];
    VirtualIP *vip = [lb.virtualIPs objectAtIndex:0];
    [self.loadBalancer.virtualIPs addObject:vip];
    selectedVirtualIP = vip;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
