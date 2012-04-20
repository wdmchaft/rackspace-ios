//
//  RSIPAddressesViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSIPAddressesViewController.h"
#import "Server.h"
#import "Image.h"
#import "LoadBalancer.h"
#import "OpenStackAccount.h"
#import "UIViewController+Conveniences.h"

// "private" class to represent IP addresses for this view
@interface RSIPAddress : NSObject
@property (nonatomic, retain) id model;
@property (nonatomic, retain) NSString *ipAddress;
@end

@implementation RSIPAddress
@synthesize model, ipAddress;
- (void)dealloc {
    [model release];
    [ipAddress release];
    [super dealloc];
}
@end

@implementation RSIPAddressesViewController

@synthesize account, ipAddresses, delegate;

- (id)initWithDelegate:(id)aDelegate account:(OpenStackAccount *)anAccount {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.delegate = aDelegate;
        self.account = anAccount;
    }
    return self;
}

- (void)loadIPs {
    
    self.ipAddresses = [[NSMutableArray alloc] init];
    
//    for (LoadBalancer
    
    for (Server *server in [self.account sortedServers]) {
        
        NSArray *publicIPs = [server.addresses objectForKey:@"public"];        
        for (NSString *ip in publicIPs) {
            
            RSIPAddress *address = [[RSIPAddress alloc] init];
            address.model = server;
            address.ipAddress = ip;
            [self.ipAddresses addObject:address];
            [address release];
            
        }
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"IP Addresses";
    [self addCancelButton];
    [self loadIPs];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.ipAddresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.account.servers count] == 0) {
        return [self tableView:tableView emptyCellWithImage:[UIImage imageNamed:@"empty-servers.png"] title:@"No Servers" subtitle:@"Tap the + button to create a new Cloud Server"];
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        // Configure the cell...
        RSIPAddress *address = [self.ipAddresses objectAtIndex:indexPath.row];
        Server *server = address.model;
        
        cell.textLabel.text = server.name;
        cell.detailTextLabel.text = address.ipAddress;
        
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate) {
        
        RSIPAddress *address = [self.ipAddresses objectAtIndex:indexPath.row];
        [self.delegate ipAddressesViewController:self didSelectIPAddress:address.ipAddress];
        [self dismissModalViewControllerAnimated:YES];
        
    }
    
}

#pragma mark - Memory Management

- (void)dealloc {
    [account release];
    [ipAddresses release];
    [super dealloc];
}

@end
