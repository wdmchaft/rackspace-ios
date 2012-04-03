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
    RSAddDomainEmailAddressSection,
    RSAddDomainTTLSection,
    RSAddDomainNumberOfSections
} RSAddDomainSectionType;

@implementation RSAddDomainViewController

@synthesize account, domainNameTextField, emailTextField, ttlTextField;

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
    BOOL becomeFirstResponder = NO;
    
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case RSAddDomainNameSection:
            cell.textLabel.text = @"Name";
            if (!self.domainNameTextField) {
                becomeFirstResponder = YES;
            }
            self.domainNameTextField = cell.textField;
            self.domainNameTextField.delegate = self;
            break;
        case RSAddDomainEmailAddressSection:
            cell.textLabel.text = @"Email";
            self.emailTextField = cell.textField;
            self.emailTextField.delegate = self;
            break;
        case RSAddDomainTTLSection:
            cell.textLabel.text = @"TTL";
            self.ttlTextField = cell.textField;
            self.ttlTextField.delegate = self;
            break;
        default:
            break;
    }
    
    if (becomeFirstResponder) {
        [cell.textField becomeFirstResponder];
    }
    
    return cell;
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    if ([textField isEqual:self.domainNameTextField]) {
        [self.emailTextField becomeFirstResponder];
    } else if ([textField isEqual:self.emailTextField]) {
        [self.ttlTextField becomeFirstResponder];
    }
    
    return NO;
}

#pragma mark - Button Handlers

- (void)saveButtonPressed:(id)sender {
  
    RSDomain *domain = [[[RSDomain alloc] init] autorelease];
    domain.name = self.domainNameTextField.text;
    domain.ttl = self.ttlTextField.text;
    domain.emailAddress = self.emailTextField.text;
    
    [[self.account.manager createDomain:domain] success:^(OpenStackRequest *request) {
        
        [self alert:nil message:[request responseString]];
        [self dismissModalViewControllerAnimated:YES];
        
    } failure:^(OpenStackRequest *request) {
        
        [self alert:@"fail" message:[request responseString]];

    }];
    
}

#pragma mark - Memory Management

- (void)dealloc {
    [account release];
    [super dealloc];
}

@end
