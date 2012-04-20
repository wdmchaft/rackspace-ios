//
//  ServersViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ServersViewController.h"
#import "OpenStackAccount.h"
#import "AddServerViewController.h"
#import "UIViewController+Conveniences.h"
#import "Server.h"
#import "Image.h"
#import "Flavor.h"
#import "ServerViewController.h"
#import "OpenStackRequest.h"
#import "RateLimit.h"
#import "OpenStackAppDelegate.h"
#import "RootViewController.h"
#import "AccountHomeViewController.h"
#import "AccountManager.h"
#import "Provider.h"
#import "APICallback.h"


@implementation ServersViewController

@synthesize tableView, account, accountHomeViewController, comingFromAccountHome;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Button Handlers

- (void)addButtonPressed:(id)sender {
    RateLimit *limit = [OpenStackRequest createServerLimit:self.account];
    if (!limit || limit.remaining > 0) {
        AddServerViewController *vc = [[AddServerViewController alloc] initWithNibName:@"AddServerViewController" bundle:nil];
        vc.account = account;
        vc.serversViewController = self;
        vc.accountHomeViewController = self.accountHomeViewController;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
            if (app.rootViewController.popoverController) {
                [app.rootViewController.popoverController dismissPopoverAnimated:YES];
            }
        }
        [self presentModalViewControllerWithNavigation:vc];
        [vc release];
    } else {
        [self alert:@"API Rate Limit Reached" message:@"You have reached your API rate limit for creating servers in this account.  Please try again when your limit has been reset."];
    }
}

- (void)selectFirstServer {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)enableRefreshButton {
    serversLoaded = YES;
    refreshButton.enabled = YES;
    [self hideToolbarActivityMessage];
}

- (void)refreshButtonPressed:(id)sender {

    refreshButton.enabled = NO;
    [self showToolbarActivityMessage:@"Refreshing servers..."];

    [[self.account.manager getServers] success:^(OpenStackRequest *request) {
        
        NSLog(@"get servers response: %@", [request responseString]);
        
        [self enableRefreshButton];
        self.account.servers = [NSMutableDictionary dictionaryWithDictionary:[request servers]];

        for (NSString *serverId in self.account.servers) {
            Server *server = [self.account.servers objectForKey:serverId];
            server.image = [self.account.images objectForKey:server.imageId];            
            server.flavor = [self.account.flavors objectForKey:server.flavorId];
        }
        
        [self.account persist];
        [self.tableView reloadData];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(selectFirstServer) userInfo:nil repeats:NO];
        }        
    } failure:^(OpenStackRequest *request) {
        [self enableRefreshButton];
        if (request.responseStatusCode != 0) {
            [self alert:@"There was a problem loading your servers." request:request];
        }
    }];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [self.account.provider isRackspace] ? @"Cloud Servers" : @"Compute";
    [self addAddButton];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        loaded = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    NSEnumerator *enumerator = [account.servers keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        Server *server = [account.servers objectForKey:key];
        
        if (!server.image && server.imageId) {

            [[self.account.manager getImage:server] success:^(OpenStackRequest *request) {
                
                NSArray *sortedServers = [self.account sortedServers];
                for (Server *server in sortedServers) {
                    BOOL updated = NO;
                    if (!server.image) {
                        server.image = [self.account.images objectForKey:server.imageId];
                        updated = YES;
                    }
                    if (updated) {
                        [self.tableView reloadData];
                    }
                }                
                
            } failure:^(OpenStackRequest *request) {
                
                NSLog(@"loading image for server %@ failed", server.name);
                
            }];
            
        }
        
    }
    
    if ([self.account.servers count] == 0) {
        self.tableView.allowsSelection = NO;
        self.tableView.scrollEnabled = NO;
        [self.tableView reloadData];
    }
    
    if (!serversLoaded && [self.account.servers count] == 0) {
        [self refreshButtonPressed:nil];
    } else if (comingFromAccountHome) {
        [self refreshButtonPressed:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.account.servers count] == 0) {
        self.tableView.allowsSelection = NO;
        self.tableView.scrollEnabled = NO;
    } else {
        self.tableView.allowsSelection = YES;
        self.tableView.scrollEnabled = YES;
    }
    if (!serversLoaded && [self.account.servers count] == 0) {
        return 0;
    } else {
        return MAX(1, [account.sortedServers count]);
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([account.servers count] == 0) {
        return aTableView.frame.size.height;
    } else {
        return aTableView.rowHeight;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    if ([self.account.servers count] == 0 && serversLoaded) {
        return [self tableView:tableView emptyCellWithImage:[UIImage imageNamed:@"empty-servers.png"] title:@"No Servers" subtitle:@"Tap the + button to create a new Cloud Server"];
    } else if ([self.account.servers count] == 0) {
        return nil; // there will be no cells present while loading
    } else {
        static NSString *CellIdentifier = @"Cell";

        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        // Configure the cell...
        Server *server = [account.sortedServers objectAtIndex:indexPath.row];
        
        cell.textLabel.text = server.name;
        if ([server.addresses objectForKey:@"public"]) {
            cell.detailTextLabel.text = [[server.addresses objectForKey:@"public"] objectAtIndex:0];
        } else {
            cell.detailTextLabel.text = @"";
        }
        
        if ([server.image respondsToSelector:@selector(logoPrefix)]) {
            if ([[server.image logoPrefix] isEqualToString:kCustomImage]) {
                cell.imageView.image = [UIImage imageNamed:kCloudServersIcon];
            } else {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
            }
        }
        
        return cell;
    }    
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Server *server = nil;
    if ([account.servers count] > 0) {
        server = [account.sortedServers objectAtIndex:indexPath.row];
    }
    ServerViewController *vc = [[ServerViewController alloc] initWithNibName:@"ServerViewController" bundle:nil];
    vc.server = server;
    vc.account = account;
    vc.serversViewController = self;
    vc.selectedServerIndexPath = indexPath;
    vc.accountHomeViewController = self.accountHomeViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self presentPrimaryViewController:vc];
        if (loaded) {
            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
            if (app.rootViewController.popoverController != nil) {
                [app.rootViewController.popoverController dismissPopoverAnimated:YES];
            }
        }
    } else {
        [self.navigationController pushViewController:vc animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [vc release];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [tableView release];
    [account release];
    [accountHomeViewController release];
    [super dealloc];
}


@end

