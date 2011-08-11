//
//  LoadBalancerViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerViewController.h"
#import "LoadBalancer.h"
#import "LoadBalancerNode.h"
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
#import "LBNodeViewController.h"
#import "Image.h"

#define kDetails 0
#define kNodes 1

#define kEnabled @"ENABLED"
#define kDisabled @"DISABLED"
#define kDraining @"DRAINING"

@implementation LoadBalancerViewController

@synthesize account, loadBalancer, tableView, titleView;

#pragma mark - Constructors and Memory Management

-(id)initWithLoadBalancer:(LoadBalancer *)lb {
    self = [self initWithNibName:@"LoadBalancerViewController" bundle:nil];
    if (self) {
        self.loadBalancer = lb;
        mode = kDetails;
        nodes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [account release];
    [loadBalancer release];
    [tableView release];
    [titleView release];
    [nodes release];
    [super dealloc];
}

#pragma mark - Utilities

- (LoadBalancerNode *)nodeForIndexPath:(NSIndexPath *)indexPath {
    LoadBalancerNode *node = nil;    
    if (indexPath.section == enabledSection) {
        node = [[nodes objectForKey:kEnabled] objectAtIndex:indexPath.row];
    } else if (indexPath.section == drainingSection) {
        node = [[nodes objectForKey:kDraining] objectAtIndex:indexPath.row];
    } else if (indexPath.section == disabledSection) {
        node = [[nodes objectForKey:kDisabled] objectAtIndex:indexPath.row];
    }
    return node;
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
    
    [self showToolbarActivityMessage:@"Loading nodes..."];
    
    [[self.account.manager getLoadBalancerDetails:self.loadBalancer endpoint:endpoint] success:^(OpenStackRequest *request) {

        [self hideToolbarActivityMessage];

        // break up nodes by condition into ENABLED, DISABLED, and DRAINING
        [nodes setObject:[NSMutableArray array] forKey:kEnabled];
        [nodes setObject:[NSMutableArray array] forKey:kDisabled];
        [nodes setObject:[NSMutableArray array] forKey:kDraining];
        
        for (LoadBalancerNode *node in loadBalancer.nodes) {
            if ([node.condition isEqualToString:kEnabled]) {
                [[nodes objectForKey:kEnabled] addObject:node];
            } else if ([node.condition isEqualToString:kDisabled]) {
                [[nodes objectForKey:kDisabled] addObject:node];
            } else if ([node.condition isEqualToString:kDraining]) {
                [[nodes objectForKey:kDraining] addObject:node];
            }                
        }
        
        // sort each node group alphabetically
        NSArray *sortedEnabled = [[nodes objectForKey:kEnabled] sortedArrayUsingSelector:@selector(compare:)];
        NSArray *sortedDisabled = [[nodes objectForKey:kDisabled] sortedArrayUsingSelector:@selector(compare:)];
        NSArray *sortedDraining = [[nodes objectForKey:kDraining] sortedArrayUsingSelector:@selector(compare:)];
        [nodes setObject:[NSMutableArray arrayWithArray:sortedEnabled] forKey:kEnabled];
        [nodes setObject:[NSMutableArray arrayWithArray:sortedDisabled] forKey:kDisabled];
        [nodes setObject:[NSMutableArray arrayWithArray:sortedDraining] forKey:kDraining];
        
        totalSections = 0;
        if ([[nodes objectForKey:kEnabled] count] > 0) {
            enabledSection = totalSections++;
        }
        if ([[nodes objectForKey:kDisabled] count] > 0) {
            disabledSection = totalSections++;
        }
        if ([[nodes objectForKey:kDraining] count] > 0) {
            drainingSection = totalSections++;
        }
        
        [self.tableView reloadData];
    } failure:^(OpenStackRequest *request) {
        [self hideToolbarActivityMessage];
        [self alert:@"There was a problem loading information for this load balancer." request:request];
    }];
    
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
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return totalSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == enabledSection) {
        return [[nodes objectForKey:kEnabled] count];
    } else if (section == drainingSection) {
        return [[nodes objectForKey:kDraining] count];
    } else if (section == disabledSection) {
        return [[nodes objectForKey:kDisabled] count];
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == enabledSection) {
        return @"Enabled Nodes";
    } else if (section == disabledSection) {
        return @"Disabled Nodes";
    } else if (section == drainingSection) {
        return @"Draining Nodes";
    } else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    LoadBalancerNode *node = [self nodeForIndexPath:indexPath];
    
    if (node.server) {
        Server *server = node.server;
        cell.textLabel.text = server.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%i", node.address, node.port];
        if ([[server.image logoPrefix] isEqualToString:@"custom"]) {
            cell.imageView.image = [UIImage imageNamed:@"cloud-servers-icon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
        }
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", node.address, node.port];
        cell.detailTextLabel.text = @"";
        cell.imageView.image = nil;
    }
    
        
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LoadBalancerNode *node = [self nodeForIndexPath:indexPath];
    LBNodeViewController *vc = [[LBNodeViewController alloc] initWithNode:node loadBalancer:self.loadBalancer account:self.account];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        vc.lbViewController = self;
        vc.lbIndexPath = indexPath;
        [self presentModalViewControllerWithNavigation:vc];
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }    
    [vc release];
}

#pragma mark - Button Handlers

- (void)configButtonPressed:(id)sender {
    ConfigureLoadBalancerViewController *vc = [[ConfigureLoadBalancerViewController alloc] initWithAccount:self.account loadBalancer:self.loadBalancer];
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self presentModalViewControllerWithNavigation:vc];
//    } else {
//        [self.navigationController pushViewController:vc animated:YES];
//    }    
    [vc release];
}

@end
