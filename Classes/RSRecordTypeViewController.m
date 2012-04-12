//
//  RSRecordTypeViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSRecordTypeViewController.h"
#import "RSRecord.h"

@interface RSRecordTypeViewController ()

@end

@implementation RSRecordTypeViewController

@synthesize delegate, selectedRecordType;

- (id)initWithDelegate:(id)aDelegate {
    
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.delegate = aDelegate;
    }
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.navigationItem.title = @"Record Type";

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[RSRecord recordTypes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *recordType = [[RSRecord recordTypes] objectAtIndex:indexPath.row];
    cell.textLabel.text = recordType;

    if ([self.selectedRecordType isEqualToString:recordType]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
        
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *recordType = [[RSRecord recordTypes] objectAtIndex:indexPath.row];
    self.selectedRecordType = recordType;
    [self.delegate recordTypeViewController:self didSelectRecordType:recordType];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    
}

#pragma mark - Memory Management

- (void)dealloc {
    [delegate release];
    [selectedRecordType release];
    [super dealloc];
}

@end
