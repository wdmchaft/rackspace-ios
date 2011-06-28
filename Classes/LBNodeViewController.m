//
//  LBNodeViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBNodeViewController.h"
#import "LoadBalancerNode.h"
#import "UIViewController+Conveniences.h"
#import "RSTextFieldCell.h"

#define kConditionSection 0
#define kEnabled 0
#define kDraining 1
#define kDisabled 2

#define kAddressSection 1
#define kIP 0
#define kPort 1

@implementation LBNodeViewController

@synthesize node;

- (id)initWithNode:(LoadBalancerNode *)n {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.node = n;
    }
    return self;
}

- (void)dealloc {
    [node release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Node Config";
    [self addSaveButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kConditionSection:
            return 3;
        case kAddressSection:
            return 2;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case kConditionSection:
            return @"When a node is set to a Draining condition, it will be disabled after it is finished servicing its current connections.";
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.section) {
        case kConditionSection:
            switch (indexPath.row) {
                case kEnabled:
                    cell.textLabel.text = @"Enabled";
                    break;
                case kDraining:
                    cell.textLabel.text = @"Draining";
                    break;
                case kDisabled:
                    cell.textLabel.text = @"Disabled";
                    break;
                default:
                    break;
            }
            if ([node.condition isEqualToString:[cell.textLabel.text uppercaseString]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case kAddressSection:
            switch (indexPath.row) {
                case kIP:
                    cell.textLabel.text = @"IP";
                    break;
                case kPort:
                    cell.textLabel.text = @"Port";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
