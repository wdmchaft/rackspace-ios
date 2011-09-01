//
//  LBNodesViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBNodesViewController.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "LoadBalancer.h"
#import "LoadBalancerNode.h"
#import "Server.h"
#import "Flavor.h"
#import "Image.h"
#import "RSTextFieldCell.h"
#import "UIViewController+Conveniences.h"
#import "LBServersViewController.h"
#import "LoadBalancerProtocol.h"
#import "ActivityIndicatorView.h"
#import "APICallback.h"
#import "AnimatedProgressView.h"

#define kNodes 0
#define kCloudServers 1

@implementation LBNodesViewController

@synthesize account, loadBalancer, isNewLoadBalancer;

- (void)dealloc {
    [account release];
    [loadBalancer release];
    [ipNodes release];
    [cloudServerNodes release];
    [nodesToDelete release];
    [super dealloc];
}

#pragma mark - Utilities

- (void)deleteEmptyIPRows {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSMutableArray *nodesToRemove = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [ipNodes count]; i++) {
        LoadBalancerNode *node = [self.loadBalancer.nodes objectAtIndex:i];
        if (!node.address || [node.address isEqualToString:@""]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:kNodes];
            [indexPaths addObject:indexPath];
            [nodesToRemove addObject:node];
        }
    }
    
    for (LoadBalancerNode *node in nodesToRemove) {
        [self.loadBalancer.nodes removeObject:node];
    }
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [indexPaths release];
    [nodesToRemove release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    saved = NO;
    self.navigationItem.title = @"Nodes";
    textFields = [[NSMutableArray alloc] init];
    ipNodes = [[NSMutableArray alloc] init];
    cloudServerNodes = [[NSMutableArray alloc] init];
    NSMutableArray *nodes = [[NSMutableArray alloc] initWithCapacity:[self.loadBalancer.nodes count]];
    for (LoadBalancerNode *node in self.loadBalancer.nodes) {
        LoadBalancerNode *copiedNode = node; //[node copy];
        [nodes addObject:copiedNode];
        if (copiedNode.server) {
            [cloudServerNodes addObject:node];
        } else {
            [ipNodes addObject:node];
        }
        //[copiedNode release];
    }
    previousNodes = [[NSArray alloc] initWithArray:nodes];
    [nodes release];        
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    if (!isNewLoadBalancer) {
        [self addSaveButton];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (isNewLoadBalancer) {
        NSMutableArray *finalNodes = [[NSMutableArray alloc] init];
        for (LoadBalancerNode *node in ipNodes) {
            if (node.address && ![node.address isEqualToString:@""]) {
                [finalNodes addObject:node];
            }
        }
        for (LoadBalancerNode *node in cloudServerNodes) {
            [finalNodes addObject:node];
        }
        if ([finalNodes count] > 0) {
            self.loadBalancer.nodes = [[[NSMutableArray alloc] initWithArray:finalNodes] autorelease];
        }
        [finalNodes release];
        self.navigationItem.rightBarButtonItem = nil;    
    } else {
        if (!saved) {
            self.loadBalancer.nodes = [NSMutableArray arrayWithArray:previousNodes];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kNodes) {
        return [ipNodes count] + 1;
    } else {
        return [cloudServerNodes count] + 1;
    }
}

- (RSTextFieldCell *)tableView:(UITableView *)tableView ipCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"IPCell%i", indexPath.row];
    
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textField.delegate = self;
        
        // tag it so we'll know which node we're editing
        cell.textField.tag = indexPath.row;
        
        cell.textField.returnKeyType = UIReturnKeyDone;
        cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [textFields addObject:cell.textField];
        
        cell.imageView.image = [UIImage imageNamed:@"red-delete-button.png"];        
    }

    if (indexPath.row < [ipNodes count]) {
        LoadBalancerNode *node = [ipNodes objectAtIndex:indexPath.row];
        cell.textField.text = node.address;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == kNodes) {
        if (indexPath.row == [ipNodes count]) {
            cell.textLabel.text = @"Add IP Address";
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"green-add-button.png"];
        } else {
            return [self tableView:tableView ipCellForRowAtIndexPath:indexPath];
        }
    } else if (indexPath.section == kCloudServers) {
        if (indexPath.row == [cloudServerNodes count]) {
            if ([cloudServerNodes count] == 0) {
                cell.textLabel.text = @"Add Cloud Servers";
            } else {
                cell.textLabel.text = @"Add/Remove Cloud Servers";
            }
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"green-add-button.png"];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            Server *server = [[cloudServerNodes objectAtIndex:indexPath.row] server];
            cell.textLabel.text = server.name;
            cell.detailTextLabel.text = server.flavor.name;
            if ([server.image respondsToSelector:@selector(logoPrefix)] && [[server.image logoPrefix] isEqualToString:kCustomImage]) {
                cell.imageView.image = [UIImage imageNamed:kCloudServersIcon];
            } else {
                if ([server.image respondsToSelector:@selector(logoPrefix)]) {
                    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
                }
            }
        }
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == kNodes && indexPath.row == [ipNodes count];
}

#pragma mark - Table view delegate

- (void)focusOnLastTextField {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[textFields count] - 1 inSection:kNodes];
    [[textFields lastObject] becomeFirstResponder];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)addIPRow {
    [self deleteEmptyIPRows];
    LoadBalancerNode *node = [[[LoadBalancerNode alloc] init] autorelease];
    node.condition = @"ENABLED";
    node.port = [NSString stringWithFormat:@"%i", self.loadBalancer.protocol.port];
    [ipNodes addObject:node];
    [self.loadBalancer.nodes addObject:node];
    NSArray *indexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[ipNodes count] - 1 inSection:kNodes]];
    [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationBottom];
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(focusOnLastTextField) userInfo:nil repeats:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kNodes) {
        if (indexPath.row == [ipNodes count]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self addIPRow];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            LoadBalancerNode *node = [ipNodes objectAtIndex:indexPath.row];
            [ipNodes removeObject:node];
            [self.loadBalancer.nodes removeObject:node];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        }
    } else if (indexPath.section == kCloudServers) {
        LBServersViewController *vc = [[LBServersViewController alloc] initWithAccount:self.account loadBalancer:self.loadBalancer serverNodes:cloudServerNodes];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self presentModalViewControllerWithNavigation:vc];
        }
        [vc release];
    }
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    if (isNewLoadBalancer) {
//        [self addDoneButton];
//    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; 
    
    if ([textField.text isEqualToString:@""]) {
        [self deleteEmptyIPRows];        
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {    
    LoadBalancerNode *node = [ipNodes objectAtIndex:textField.tag];    
    node.address = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

#pragma mark - Button Handlers

//- (void)doneButtonPressed:(id)sender {
//    for (UITextField *textField in textFields) {
//        [textField resignFirstResponder];
//    }
//    self.navigationItem.rightBarButtonItem = nil;
//}

- (void)deleteNodeProgress {
    currentAPICalls++;
    NSLog(@"((%i / 1.0) / %i) = %f", currentAPICalls, totalAPICalls, ((currentAPICalls / 1.0) / totalAPICalls));
    [spinner.progressView setProgress:((currentAPICalls / 1.0) / totalAPICalls) animated:YES];
    
    if (currentAPICalls == totalAPICalls) {
        [spinner removeFromSuperviewAndRelease]; 
    }
}

- (void)deleteNode:(LoadBalancerNode *)node {
    
    NSLog(@"trying to delete node %@", node.identifier);
    
    NSString *endpoint = [self.account loadBalancerEndpointForRegion:self.loadBalancer.region];
    
    APICallback *callback = [self.account.manager deleteLBNode:node loadBalancer:self.loadBalancer endpoint:endpoint];
    
    __block void (^callBackBlock)(OpenStackRequest *request);        
    callBackBlock = ^(OpenStackRequest *request) {
        
        deleteIndex++;
        [self deleteNodeProgress];

        if (![request isSuccess]) {
            [self alert:@"There was a problem deleting a node." request:request];
        } else {
            self.loadBalancer.status = @"PENDING_UPDATE";
        }
        
        
        if (deleteIndex < [nodesToDelete count]) {

            self.loadBalancer.status = @"PENDING_UPDATE";            
            [self.loadBalancer pollUntilActive:self.account delegate:self completeSelector:@selector(deleteNode:) object:[nodesToDelete objectAtIndex:deleteIndex]];
            
            //                [self.loadBalancer pollUntilActive:self.account complete:^{
            //                    deleteNodeBlock([nodesToDelete objectAtIndex:deleteIndex]);
            //                }];
        };
        
    };
    
    [callback success:callBackBlock failure:callBackBlock];    
}

- (void)deleteNodesWithProgress:(ASIBasicBlock)progressBlock {
    
    NSString *endpoint = [self.account loadBalancerEndpointForRegion:self.loadBalancer.region];
    deleteIndex = 0;
    
    __block void (^deleteNodeBlock)(LoadBalancerNode *node);
    deleteNodeBlock = ^(LoadBalancerNode *node) {
        
        NSLog(@"trying to delete node %@", node.identifier);
        
        APICallback *callback = [self.account.manager deleteLBNode:node loadBalancer:self.loadBalancer endpoint:endpoint];
        
        __block void (^callBackBlock)(OpenStackRequest *request);        
        callBackBlock = ^(OpenStackRequest *request) {
            
            deleteIndex++;
            [self deleteNodeProgress];
            
            if (deleteIndex < [nodesToDelete count]) {
                self.loadBalancer.status = @"PENDING_UPDATE";            
                [self.loadBalancer pollUntilActive:self.account delegate:self completeSelector:@selector(deleteNode:) object:[nodesToDelete objectAtIndex:deleteIndex]];
                
//                [self.loadBalancer pollUntilActive:self.account complete:^{
//                    deleteNodeBlock([nodesToDelete objectAtIndex:deleteIndex]);
//                }];
            };
            
            if (![request isSuccess]) {
                [self alert:@"There was a problem deleting a node." request:request];
            }
        };

        [callback success:callBackBlock failure:callBackBlock];
        
    };

    LoadBalancerNode *node = [nodesToDelete objectAtIndex:deleteIndex];
    deleteNodeBlock(node);
    
}
    
- (void)addNodes:(NSArray *)nodesToAdd andDeleteNodesWithProgress:(ASIBasicBlock)progressBlock failure:(APIResponseBlock)failureBlock {

    NSString *endpoint = [self.account loadBalancerEndpointForRegion:self.loadBalancer.region];    
    
    if ([nodesToAdd count] > 0) {
        // we want to add before doing any deletes to avoid attempting an invalid delete
        APICallback *callback = [self.account.manager addLBNodes:nodesToAdd loadBalancer:self.loadBalancer endpoint:endpoint];
        [callback success:^(OpenStackRequest *request) {
            
            // if it's a successful add, the status will be PENDING_UPDATE.  cheaper
            // to just set it than hit the API again since we're already going to hit it
            // n times for the deletes
            self.loadBalancer.status = @"PENDING_UPDATE";

            [self deleteNodeProgress];
            
            if ([nodesToDelete count] > 0) {            
                // before you delete, you need to poll the LB until it hits active status
                [self.loadBalancer pollUntilActive:self.account complete:^{
                    [self deleteNodesWithProgress:progressBlock];
                }];
            }
            
        } failure:^(OpenStackRequest *request) {
            failureBlock(request);
        }];
    } else {
        [self deleteNodesWithProgress:progressBlock];
    }
    
}

- (void)saveButtonPressed:(id)sender {
    
    if ([self.loadBalancer.nodes count] == 0) {
        [self alert:nil message:@"You must have at least one node attached to this load balancer."];
        return;
    } else {
        NSInteger enabledCount = 0;
        for (LoadBalancerNode *node in self.loadBalancer.nodes) {
            if ([node.condition isEqualToString:@"ENABLED"]) {
                enabledCount++;
            }
        }
        if (enabledCount == 0) {
            [self alert:nil message:@"You must have at least one enabled node attached to this load balancer."];
            return;
        }
    }
    
    
    
    // we need to compare the previousNodoes list to the current nodes list so we
    // can know which nodes to add and which ones to delete
    NSMutableArray *nodesToAdd = [[NSMutableArray alloc] init];
    nodesToDelete = [[NSMutableArray alloc] init];
    
    NSLog(@"previous nodes: %@", previousNodes);
    NSLog(@"lb nodes: %@", self.loadBalancer.nodes);
    
    for (LoadBalancerNode *node in previousNodes) {
        if (![self.loadBalancer.nodes containsObject:node]) {
            [nodesToDelete addObject:node];
            NSLog(@"going to delete node: %@", node);
        }
    }
    
    for (LoadBalancerNode *node in self.loadBalancer.nodes) {
        if (![previousNodes containsObject:node]) {
            [nodesToAdd addObject:node];
            NSLog(@"going to add node: %@", node);
        }
    }

    currentAPICalls = 0;
    totalAPICalls = [nodesToDelete count] + ([nodesToAdd count] > 0 ? 1 : 0);

    if (totalAPICalls > 0) {
        spinner = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Saving..." withProgress:YES] text:@"Saving..." withProgress:YES];
        [spinner addToView:self.view];
        
        saved = YES;
        
        // make the API calls
        [self addNodes:nodesToAdd andDeleteNodesWithProgress:^{
            currentAPICalls++;
            // TODO: update progress view on spinner
            if (currentAPICalls == totalAPICalls) {
                [spinner removeFromSuperviewAndRelease]; 
            }
        } failure:^(OpenStackRequest *request) {
            [self alert:@"There was a problem adding nodes." request:request];
            [spinner removeFromSuperviewAndRelease];
        }];
    } else {
        [self alert:nil message:@"You did not select any nodes to add or remove."];
    }
    
    [nodesToAdd release];
}

@end
