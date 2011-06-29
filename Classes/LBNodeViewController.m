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
#import "UIColor+MoreColors.h"

#define kConditionSection 0
#define kEnabled 0
#define kDraining 1
#define kDisabled 2

#define kRemoveNode 1

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
    self.navigationItem.title = self.node.address;
    
    [self alert:nil message:[self.node toJSON]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kConditionSection) {
        return 3;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kConditionSection) {
        return @"Draining nodes are disabled after all current connections are completed.";
    } else {
        return @"";
    }
}

- (UITableViewCell *)removeNodeCell {
    static NSString *CellIdentifier = @"RemoveNodeCell";    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor value1DetailTextLabelColor];
        cell.textLabel.text = @"Remove Node";
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kRemoveNode) {
        return [self removeNodeCell];
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        
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
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kConditionSection) {
        switch (indexPath.row) {
            case kEnabled:
                self.node.condition = @"ENABLED";
                break;
            case kDraining:
                self.node.condition = @"DRAINING";
                break;
            case kDisabled:
                self.node.condition = @"DISABLED";
                break;
            default:
                break;
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.35 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
    } else {
        [self alert:nil message:@"remove node"];
    }
}

@end
