//
//  ConfigureLoadBalancerViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigureLoadBalancerViewController.h"
#import "LoadBalancer.h"
#import "LBProtocolViewController.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "RSTextFieldCell.h"
#import "LBNodesViewController.h"
#import "LBAlgorithmViewController.h"
#import "AddLoadBalancerAlgorithmViewController.h"
#import "LoadBalancerProtocol.h"
#import "UIViewController+Conveniences.h"
#import "OpenStackRequest.h"
#import "APICallback.h"
#import "UIColor+MoreColors.h"

#define kDetailsSection 0
#define kNodesSection 1
#define kConnectionLoggingSection 2
#define kDeleteSection 3

#define kName 0
#define kProtocol 1
#define kVirtualIPType 2
#define kRegion 3
#define kAlgorithm 4

@implementation ConfigureLoadBalancerViewController

@synthesize account, loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)a loadBalancer:(LoadBalancer *)lb {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.account = a;
        self.loadBalancer = lb;
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
    self.navigationItem.title = @"Configure";
    [self addSaveButton];
    
    algorithmNames = [[NSDictionary alloc] initWithObjectsAndKeys:
                      @"Random",@"RANDOM", 
                      @"Round Robin", @"ROUND_ROBIN", 
                      @"Weighted Round Robin", @"WEIGHTED_ROUND_ROBIN", 
                      @"Least Connections", @"LEAST_CONNECTIONS", 
                      @"Weighted Least Connections", @"WEIGHTED_LEAST_CONNECTIONS", 
                      nil];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
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
    }
    
    cell.textField.text = self.loadBalancer.name;
    
    return cell;
}

- (UITableViewCell *)connectionLoggingCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"ConnectionLoggingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.text = @"Connection Logging";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwitch *clSwitch = [[UISwitch alloc] init];
        clSwitch.on = self.loadBalancer.connectionLoggingEnabled;
        [clSwitch addTarget:self action:@selector(connectionLoggingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = clSwitch;
        [clSwitch release];
    }
    
    NSLog(@"self.loadBalancer.connectionLoggingEnabled = %i", self.loadBalancer.connectionLoggingEnabled);
    ((UISwitch *)cell.accessoryView).on = self.loadBalancer.connectionLoggingEnabled;
    
    return cell;
}

- (UITableViewCell *)deleteCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"DeleteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.text = @"Delete Load Balancer";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor value1DetailTextLabelColor];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kDetailsSection && indexPath.row == kName) {
        return [self nameCell:tableView];
    } else if (indexPath.section == kConnectionLoggingSection) {
        return [self connectionLoggingCell:tableView];
    } else if (indexPath.section == kDeleteSection) {
        return [self deleteCell:tableView];
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
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                break;
            case kVirtualIPType:
                cell.textLabel.text = @"Virtual IP Type";
                cell.detailTextLabel.text = self.loadBalancer.virtualIPType;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case kRegion:
                cell.textLabel.text = @"Region";
                cell.detailTextLabel.text = self.loadBalancer.region;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case kAlgorithm:
                cell.textLabel.text = @"Algorithm";
                cell.detailTextLabel.text = [algorithmNames objectForKey:self.loadBalancer.algorithm];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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
        
        if ([self.loadBalancer.nodes count] + [self.loadBalancer.cloudServerNodes count] == 1) {
            cell.detailTextLabel.text = @"1 Node";
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i Nodes", [self.loadBalancer.nodes count] + [self.loadBalancer.cloudServerNodes count]];
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
        vc.isNewLoadBalancer = NO;
        vc.account = self.account;
        vc.loadBalancer = self.loadBalancer;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];        
    } else if (indexPath.section == kDeleteSection) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this load balancer?  This operation cannot be undone." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Load Balancer" otherButtonTitles:nil];
        [sheet showInView:self.view];
        [sheet release];
    } else if (indexPath.row == kProtocol) {
        LBProtocolViewController *vc = [[LBProtocolViewController alloc] initWithAccount:self.account loadBalancer:self.loadBalancer];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.row == kAlgorithm) {
        LBAlgorithmViewController *vc = [[LBAlgorithmViewController alloc] initWithLoadBalancer:self.loadBalancer];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[self.account.manager deleteLoadBalancer:self.loadBalancer] success:^(OpenStackRequest *request) {
            NSLog(@"delete response %i: %@", request.responseStatusCode, [request responseString]);
            [self.navigationController popViewControllerAnimated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(OpenStackRequest *request) {
            [self alert:@"There was a problem deleting the load balancer." request:request];
        }];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:kDeleteSection];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)saveButtonPressed:(id)sender {
    [[self.account.manager updateLoadBalancer:self.loadBalancer] success:^(OpenStackRequest *request) {
    } failure:^(OpenStackRequest *request) {
        [self alert:@"There was a problem updating this load balancer." request:request];
    }];
}

#pragma mark - Connection Logging Switch

- (void)connectionLoggingSwitchChanged:(UISwitch *)sender {
    self.loadBalancer.connectionLoggingEnabled = sender.on;
    [[self.account.manager updateLoadBalancerConnectionLogging:self.loadBalancer] success:^(OpenStackRequest *request) { 
    } failure:^(OpenStackRequest *request) {
        [self alert:@"There was a problem updating the load balancer." request:request];
    }];
}

@end
