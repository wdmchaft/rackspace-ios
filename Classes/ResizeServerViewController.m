//
//  ResizeServerViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 2/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ResizeServerViewController.h"
#import "ServerViewController.h"
#import "UIViewController+Conveniences.h"
#import "OpenStackAccount.h"
#import "Server.h"
#import "Flavor.h"
#import "AccountManager.h"
#import "Provider.h"

#define kResizeButton 0
#define kCancelButton 1

@implementation ResizeServerViewController

@synthesize account, server;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == kResizeButton) {
        
        [self.account.manager resizeServer:self.server flavor:selectedFlavor];
        [serverViewController showToolbarActivityMessage:@"Resizing server..."];
        [self dismissModalViewControllerAnimated:YES];    
        [serverViewController.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:kResize inSection:kActions] animated:YES];
        
    }
    
}

#pragma mark - Button Handlers

- (void)saveButtonPressed:(id)sender {

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to resize this server?  You may experience downtime while the server is being resized." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Resize Server" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
    
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    selectedFlavor = self.server.flavor;
    [tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.account.flavors count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [self.account.provider isRackspace] ? @"Resizes will be charged or credited a prorated amount based upon the difference in cost and the number of days remaining in your billing cycle." : @"";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    Flavor *flavor = [self.account.sortedFlavors objectAtIndex:indexPath.row];
	cell.textLabel.text = flavor.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%iMB RAM, %iGB Disk", flavor.ram, flavor.disk];
	
	if (flavor.identifier == selectedFlavor.identifier) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedFlavor = [self.account.sortedFlavors objectAtIndex:indexPath.row];    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:aTableView selector:@selector(reloadData) userInfo:nil repeats:NO];
}

#pragma mark - Memory management

- (void)dealloc {
	[account release];
    [server release];
    [super dealloc];
}

@end

