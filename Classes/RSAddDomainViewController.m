//
//  RSAddDomainViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSAddDomainViewController.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "RSDomain.h"
#import "UIViewController+Conveniences.h"
#import "RSTextFieldCell.h"

/*
 Name: example.com
 TTL:  [slider]
 Comment: (limited to 160 characters)
 Email Address: [type or choose from contacts]
 */

typedef enum {
    RSAddDomainNameSection,
    RSAddDomainTTLSection,
    RSAddDomainCommentSection,
    RSAddDomainEmailAddressSection,
    RSAddDomainNumberOfSections
} RSAddDomainSectionType;

@implementation RSAddDomainViewController

@synthesize account;

- (id)initWithAccount:(OpenStackAccount *)anAccount {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.account = anAccount;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.navigationItem.title = @"Add Domain";

    [self addCancelButton];
    [self addSaveButton];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return RSAddDomainNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)saveButtonPressed:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma mark - Memory Management

- (void)dealloc {
    [account release];
    [super dealloc];
}

@end
