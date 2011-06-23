//
//  LoadBalancerViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerViewController.h"
#import "LoadBalancer.h"
#import <QuartzCore/QuartzCore.h>
#import "LBTitleView.h"
#import "LoadBalancerProtocol.h"
#import "Server.h"
#import "ConfigureLoadBalancerViewController.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "APICallback.h"
#import "LoadBalancerUsage.h"
#import "NSObject+Conveniences.h"
#import "VirtualIP.h"
#import "UIViewController+Conveniences.h"

#define kDetails 0
#define kNodes 1

@implementation LoadBalancerViewController

@synthesize account, loadBalancer, tableView, titleView;

-(id)initWithLoadBalancer:(LoadBalancer *)lb {
    self = [self initWithNibName:@"LoadBalancerViewController" bundle:nil];
    if (self) {
        self.loadBalancer = lb;
        mode = kDetails;
    }
    return self;
}

- (void)dealloc {
    [account release];
    [loadBalancer release];
    [tableView release];
    [titleView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Load Balancer";
    previousScrollPoint = CGPointZero;
    
    if (!titleView) {        
        titleView = [[LBTitleView alloc] initWithLoadBalancer:self.loadBalancer];
        [self.view addSubview:titleView];
        [titleView setNeedsDisplay];
    }    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *configure = [[UIBarButtonItem alloc] initWithTitle:@"Configure" style:UIBarButtonItemStyleBordered target:self action:@selector(configButtonPressed:)];
    self.navigationItem.rightBarButtonItem = configure;
    [configure release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *endpoint = [self.account loadBalancerEndpointForRegion:self.loadBalancer.region];
    
    [[self.account.manager getLoadBalancerUsage:self.loadBalancer endpoint:endpoint] success:^(OpenStackRequest *request) {
        self.titleView.connectedLabel.text = [NSString stringWithFormat:@"%.0f connected", self.loadBalancer.usage.averageNumConnections];
        self.titleView.bwInLabel.text = [NSString stringWithFormat:@"%@ in", [LoadBalancerUsage humanizedBytes:self.loadBalancer.usage.incomingTransfer]];
        self.titleView.bwOutLabel.text = [NSString stringWithFormat:@"%@ out", [LoadBalancerUsage humanizedBytes:self.loadBalancer.usage.outgoingTransfer]];
    } failure:^(OpenStackRequest *request) {
        self.titleView.connectedLabel.text = @"";
        self.titleView.bwInLabel.text = @"";
        self.titleView.bwOutLabel.text = @"";
    }];
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loadBalancer.virtualIPs count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    
    VirtualIP *ip = [self.loadBalancer.virtualIPs objectAtIndex:indexPath.row];
    cell.textLabel.text = ip.address;
        
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
}

#pragma mark - Button Handlers

- (void)configButtonPressed:(id)sender {
    ConfigureLoadBalancerViewController *vc = [[ConfigureLoadBalancerViewController alloc] initWithAccount:self.account loadBalancer:self.loadBalancer];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

@end
