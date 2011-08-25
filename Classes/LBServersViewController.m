//
//  LBServersViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBServersViewController.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "LoadBalancer.h"
#import "Server.h"
#import "Flavor.h"
#import "Image.h"
#import "UIViewController+Conveniences.h"
#import "ActivityIndicatorView.h"
#import "APICallback.h"
#import "LoadBalancerNode.h"
#import "LoadBalancerProtocol.h"


@implementation LBServersViewController

@synthesize account, loadBalancer, serverNodes, originalServerNodes;

- (id)initWithAccount:(OpenStackAccount *)a loadBalancer:(LoadBalancer *)lb serverNodes:(NSMutableArray *)sn {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self = [super initWithStyle:UITableViewStyleGrouped];
    } else {
        self = [super initWithStyle:UITableViewStylePlain];
    }
    if (self) {
        self.account = a;
        self.loadBalancer = lb;
        self.serverNodes = sn;
        self.originalServerNodes = [[sn copy] autorelease];
    }
    return self;
}

- (void)dealloc {
    [account release];
    [loadBalancer release];
    [serverNodes release];
    [originalServerNodes release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Cloud Servers";
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self addDoneButton];
    }
    
    if ([self.account.servers count] == 0) {
        // we may not have loaded the servers yet, so load them now
        
        NSString *activityMessage = @"Loading...";
        ActivityIndicatorView *activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
        [activityIndicatorView addToView:self.view];
        
        [[self.account.manager getServersWithCallback] success:^(OpenStackRequest *request) {
            [activityIndicatorView removeFromSuperviewAndRelease];
            [self.tableView reloadData];
        } failure:^(OpenStackRequest *request) {
            [activityIndicatorView removeFromSuperviewAndRelease];
            [self alert:@"There was a problem loading your servers." request:request];
        }];
        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.account.sortedServers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Server *server = [self.account.sortedServers objectAtIndex:indexPath.row];
    cell.textLabel.text = server.name;
    cell.detailTextLabel.text = server.flavor.name;
    if ([server.image respondsToSelector:@selector(logoPrefix)]) {
        if ([[server.image logoPrefix] isEqualToString:@"custom"]) {
            cell.imageView.image = [UIImage imageNamed:@"cloud-servers-icon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
        }
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
    for (LoadBalancerNode *node in self.serverNodes) {
        if ([node.server isEqual:server]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Server *server = [self.account.sortedServers objectAtIndex:indexPath.row];
    LoadBalancerNode *nodeToRemove = nil;
    for (LoadBalancerNode *node in self.serverNodes) {
        if ([node.server isEqual:server]) {
            nodeToRemove = node;
        }
    }
    
    if (nodeToRemove) {
        [self.serverNodes removeObject:nodeToRemove];
    } else {
        LoadBalancerNode *node = [[LoadBalancerNode alloc] init];
        node.condition = @"ENABLED";
        node.server = server;
        node.address = [[server.addresses objectForKey:@"public"] objectAtIndex:0];
        node.port = [NSString stringWithFormat:@"%i", self.loadBalancer.protocol.port];
        [self.serverNodes addObject:node];
        [node release];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
}

#pragma mark - Button Handlers

- (void)doneButtonPressed:(id)sender {
    
    // compare original nodes to current nodes and alter the LB
    NSMutableArray *nodesToAdd = [[NSMutableArray alloc] init];
    NSMutableArray *nodesToDelete = [[NSMutableArray alloc] init];
    
    NSLog(@"original nodes: %@", self.originalServerNodes);
    NSLog(@"current nodes: %@", self.serverNodes);

    for (LoadBalancerNode *node in self.originalServerNodes) {
        if (![self.serverNodes containsObject:node]) {
            [nodesToDelete addObject:node];
            NSLog(@"going to delete: %@", node);
        }
    }
    
    for (LoadBalancerNode *node in self.serverNodes) {
        if (![self.originalServerNodes containsObject:node]) {
            [nodesToAdd addObject:node];
            NSLog(@"going to add: %@", node);
        }
    }
    
    for (LoadBalancerNode *node in nodesToAdd) {
        [self.loadBalancer.nodes addObject:node];
    }

    for (LoadBalancerNode *node in nodesToDelete) {
        [self.loadBalancer.nodes removeObject:node];
    }
    
    [nodesToDelete release];
    [nodesToAdd release];
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
