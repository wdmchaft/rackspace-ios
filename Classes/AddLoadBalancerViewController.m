//
//  AddLoadBalancerNameViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddLoadBalancerViewController.h"
#import "OpenStackAccount.h"
#import "UIViewController+Conveniences.h"
#import "RSTextFieldCell.h"
#import "UIColor+MoreColors.h"
#import "AddLoadBalancerAlgorithmViewController.h"
#import "LoadBalancer.h"
#import "LBProtocolViewController.h"
#import "LBVirtualIPTypeViewController.h"
#import "AddLoadBalancerRegionViewController.h"
#import "LBAlgorithmViewController.h"
#import "Server.h"
#import "Flavor.h"
#import "Image.h"
#import "LoadBalancerNode.h"
#import "LBNodesViewController.h"
#import "LoadBalancerProtocol.h"
#import "AccountManager.h"
#import "APICallback.h"

#define kDetailsSection 0
#define kNodesSection 1

#define kName 0
#define kProtocol 1
#define kVirtualIPType 2
#define kRegion 3
#define kAlgorithm 4

@implementation AddLoadBalancerViewController

@synthesize account, loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)a {
    self = [super initWithNibName:@"AddLoadBalancerNameViewController" bundle:nil];
    if (self) {
        self.account = a;
        self.loadBalancer = [[[LoadBalancer alloc] init] autorelease];
        self.loadBalancer.virtualIPType = @"Public";
        self.loadBalancer.region = [self.account.loadBalancerRegions objectAtIndex:0];
        self.loadBalancer.algorithm = @"RANDOM";
        self.loadBalancer.protocol = [[[LoadBalancerProtocol alloc] init] autorelease];
        self.loadBalancer.protocol.name = @"HTTP";
        self.loadBalancer.protocol.port = 80;
    }
    return self;
}

- (void)dealloc {
    [account release];
    [loadBalancer release];
    [algorithmNames release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add Load Balancer";
    [self addSaveButton];
    [self addCancelButton];
    
    algorithmNames = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @"Random", @"RANDOM", 
                       @"Round Robin", @"ROUND_ROBIN", 
                       @"Weighted Round Robin", @"WEIGHTED_ROUND_ROBIN", 
                       @"Least Connections", @"LEAST_CONNECTIONS", 
                       @"Weighted Least Connections", @"WEIGHTED_LEAST_CONNECTIONS", 
                       nil];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kDetailsSection) {
        return 5;
    } else {
        return 1;
    }
}

- (UITableViewCell *)nameCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"NameCell";
    
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.text = @"Name";
        cell.textField.delegate = self;
        nameTextField = cell.textField;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kDetailsSection && indexPath.row == kName) {
        return [self nameCell:tableView];
    } else if (indexPath.section == kDetailsSection) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        switch (indexPath.row) {
            case kProtocol:
                cell.textLabel.text = @"Protocol";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%i", self.loadBalancer.protocol.name, self.loadBalancer.protocol.port];
                break;
            case kVirtualIPType:
                cell.textLabel.text = @"Virtual IP Type";
                cell.detailTextLabel.text = self.loadBalancer.virtualIPType;
                break;
            case kRegion:
                cell.textLabel.text = @"Region";
                cell.detailTextLabel.text = self.loadBalancer.region;
                break;
            case kAlgorithm:
                cell.textLabel.text = @"Algorithm";
                cell.detailTextLabel.text = [algorithmNames objectForKey:self.loadBalancer.algorithm];
                break;
            default:
                break;
        }
        
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"NodeCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.text = @"Nodes";
        
        if ([self.loadBalancer.nodes count] == 1) {
            cell.detailTextLabel.text = @"1 Node";
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i Nodes", [self.loadBalancer.nodes count]];
        }

        return cell;
    }
}

#pragma mark - Table view delegate

- (void)nextButtonPressed:(id)sender {
    AddLoadBalancerAlgorithmViewController *vc = [[AddLoadBalancerAlgorithmViewController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kNodesSection) {
        LBNodesViewController *vc = [[LBNodesViewController alloc] initWithNibName:@"LBNodesViewController" bundle:nil];
        vc.isNewLoadBalancer = YES;
        vc.account = self.account;
        vc.loadBalancer = self.loadBalancer;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];        
    } else if (indexPath.row == kProtocol) {
        LBProtocolViewController *vc = [[LBProtocolViewController alloc] initWithAccount:self.account loadBalancer:self.loadBalancer];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.row == kVirtualIPType) {
        LBVirtualIPTypeViewController *vc = [[LBVirtualIPTypeViewController alloc] initWithAccount:self.account loadBalancer:self.loadBalancer];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.row == kRegion) {
        AddLoadBalancerRegionViewController *vc = [[AddLoadBalancerRegionViewController alloc] initWithAccount:self.account];
        vc.loadBalancer = self.loadBalancer;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.row == kAlgorithm) {
        LBAlgorithmViewController *vc = [[LBAlgorithmViewController alloc] initWithLoadBalancer:self.loadBalancer];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

#pragma mark - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.loadBalancer.name = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Button Handlers

- (void)saveLoadBalancer {
    // TODO: show "saving" spinner and refresh list when dismissing
    [[self.account.manager createLoadBalancer:self.loadBalancer] success:^(OpenStackRequest *request) {
        [self dismissModalViewControllerAnimated:YES];
    } failure:^(OpenStackRequest *request) {
        [self alert:@"There was a problem creating the load balancer." request:request];
    }];
}

- (void)saveButtonPressed:(id)sender {
    if (self.loadBalancer.name && ![@"" isEqualToString:self.loadBalancer.name]) {        
        if (self.loadBalancer.nodes && [self.loadBalancer.nodes count] > 0) {
            [self saveLoadBalancer];
        } else {
            [self alert:nil message:@"Please add at least one node."];
        }
    } else {
        [self alert:nil message:@"Please enter a name."];
        [nameTextField becomeFirstResponder];
    }
    
    
}

@end
