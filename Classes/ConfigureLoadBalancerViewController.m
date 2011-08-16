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
#import "VirtualIP.h"
#import "Analytics.h"
#import "PingIPAddressViewController.h"
#import "LoadBalancersViewController.h"
#import "LoadBalancerViewController.h"

#define kDetailsSection 0
#define kRegionSection 1
#define kVirtualIPsSection 2
#define kNodesSection 3
#define kConnectionLoggingSection 4
#define kDeleteSection 5

#define kName 0
#define kProtocol 1
#define kAlgorithm 2

#define kVirtualIPType 0
#define kRegion 1

@implementation ConfigureLoadBalancerViewController

@synthesize account, loadBalancer, loadBalancerViewController;

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
    [deleteActionSheet release];
    [ipActionSheet release];
    [loadBalancerViewController release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Configure";
    [self addSaveButton];
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self addCancelButton];
//    }
    
    algorithmNames = [[NSDictionary alloc] initWithObjectsAndKeys:
                      @"Random",@"RANDOM", 
                      @"Round Robin", @"ROUND_ROBIN", 
                      @"Weighted Round Robin", @"WEIGHTED_ROUND_ROBIN", 
                      @"Least Connections", @"LEAST_CONNECTIONS", 
                      @"Weighted Least Connections", @"WEIGHTED_LEAST_CONNECTIONS", 
                      nil];
    
    ipActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Ping IP Address", @"Copy to Pasteboard", @"Open in Safari", nil];
    deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this load balancer?  This operation cannot be undone." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Load Balancer" otherButtonTitles:nil];
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
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kDetailsSection) {
        return 3;
    } else if (section == kRegionSection) {
        return 2;
    } else if (section == kVirtualIPsSection) {
        return [self.loadBalancer.virtualIPs count];
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
    } else if (indexPath.section == kRegionSection) {
        static NSString *CellIdentifier = @"RegionCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        switch (indexPath.row) {
            case kVirtualIPType:
                cell.textLabel.text = @"Virtual IP Type";
                cell.detailTextLabel.text = self.loadBalancer.virtualIPType;
                break;
            case kRegion:
                cell.textLabel.text = @"Region";
                cell.detailTextLabel.text = self.loadBalancer.region;
                break;
            default:
                break;
        }
        
        return cell;
        
    } else if (indexPath.section == kVirtualIPsSection) {
        static NSString *CellIdentifier = @"VIPCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        VirtualIP *vip = [self.loadBalancer.virtualIPs objectAtIndex:indexPath.row];        
        cell.textLabel.text = [vip.type capitalizedString];
        cell.detailTextLabel.text = vip.address;
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kVirtualIPsSection) {
        VirtualIP *vip = [self.loadBalancer.virtualIPs objectAtIndex:indexPath.row];
        selectedVirtualIP = vip;
        selectedVIPIndexPath = indexPath;        
        ipActionSheet.title = vip.address;
        [ipActionSheet showInView:self.view];
    } else if (indexPath.section == kNodesSection) {
        LBNodesViewController *vc = [[LBNodesViewController alloc] initWithNibName:@"LBNodesViewController" bundle:nil];
        vc.isNewLoadBalancer = NO;
        vc.account = self.account;
        vc.loadBalancer = self.loadBalancer;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];        
    } else if (indexPath.section == kDeleteSection) {
        [deleteActionSheet showInView:self.view];
    } else if (indexPath.section == kDetailsSection) {
        if (indexPath.row == kProtocol) {
            LBProtocolViewController *vc = [[LBProtocolViewController alloc] initWithAccount:self.account loadBalancer:self.loadBalancer];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        } else if (indexPath.row == kAlgorithm) {
            LBAlgorithmViewController *vc = [[LBAlgorithmViewController alloc] initWithLoadBalancer:self.loadBalancer];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
    }
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == deleteActionSheet) {
        if (buttonIndex == 0) {            
            [[self.account.manager deleteLoadBalancer:self.loadBalancer] success:^(OpenStackRequest *request) {                
                LoadBalancersViewController *vc = [[self.loadBalancerViewController.navigationController viewControllers] objectAtIndex:2];                
                [vc refreshButtonPressed:nil];
                [self dismissModalViewControllerAnimated:YES];
                [self.loadBalancerViewController.navigationController popToViewController:vc animated:YES];
            } failure:^(OpenStackRequest *request) {
                [self alert:@"There was a problem deleting the load balancer." request:request];
            }];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:kDeleteSection];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (actionSheet == ipActionSheet) {
        if (buttonIndex == 0) { // ping
            TrackEvent(CATEGORY_LOAD_BALANCER, EVENT_PINGED);            
            PingIPAddressViewController *vc = [[PingIPAddressViewController alloc] initWithNibName:@"PingIPAddressViewController" bundle:nil ipAddress:selectedVirtualIP.address];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                vc.modalPresentationStyle = UIModalPresentationPageSheet;
            }                
            [self.navigationController presentModalViewController:vc animated:YES];
            [vc release];
        } else if (buttonIndex == 1) { // copy to pasteboard
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:selectedVirtualIP.address];
            [self.tableView deselectRowAtIndexPath:selectedVIPIndexPath animated:YES];
        } else if (buttonIndex == 2) { // open in safari
            UIApplication *application = [UIApplication sharedApplication];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", selectedVirtualIP.address]];
            if ([application canOpenURL:url]) {
                [application openURL:url];
            }
        }
        [self.tableView deselectRowAtIndexPath:selectedVIPIndexPath animated:YES];
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

- (void)saveButtonPressed:(id)sender {
    [[self.account.manager updateLoadBalancer:self.loadBalancer] success:^(OpenStackRequest *request) {
        [self dismissModalViewControllerAnimated:YES];
    } failure:^(OpenStackRequest *request) {
        [self alert:@"There was a problem updating this load balancer." request:request];
    }];
}

- (void)cancelButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
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
