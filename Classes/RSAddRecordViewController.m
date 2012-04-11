//
//  RSAddRecordViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSAddRecordViewController.h"
#import "RSTextFieldCell.h"
#import "RSRecord.h"

typedef enum {
    RSRecordNameRow,
    RSRecordTypeRow,
    RSRecordDataRow,
    RSRecordMoreInfoRow,
    RSRecordNumberOfRows
} RSRecordRowType;

@interface RSAddRecordViewController ()

@end

@implementation RSAddRecordViewController

@synthesize account, nameTextField, typeTextField, dataTextField, recordType;

- (id)initWithAccount:(OpenStackAccount *)anAccount {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.account = anAccount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (!self.recordType) {
        self.recordType = [[RSRecord recordTypes] objectAtIndex:0];
    }

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RSRecordNumberOfRows;
}

- (Class)cellClassForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == RSRecordTypeRow) {
        return [UITableViewCell class];
    } else {
        return [RSTextFieldCell class];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Class klass = [self cellClassForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(klass)];
    if (cell == nil) {
        cell = [[[klass alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass(klass)] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.row) {
        case RSRecordNameRow:
            cell.textLabel.text = @"Name";
            break;            
        case RSRecordTypeRow:
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = self.recordType;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;            
        case RSRecordDataRow:
            cell.textLabel.text = @"Data";
            break;            
        case RSRecordMoreInfoRow:
            cell.textLabel.text = @"More Info";
            cell.detailTextLabel.text = @"";
            break;            
        default:
            break;
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    if (indexPath.row == RSRecordTypeRow) {
        
        RSRecordTypeViewController *vc = [[RSRecordTypeViewController alloc] initWithDelegate:self];
        vc.selectedRecordType = self.recordType;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        
    }
    
}

#pragma mark - RSRecordTypeViewControllerDelegate

- (void)recordTypeViewController:(RSRecordTypeViewController *)recordTypeViewController didSelectRecordType:(NSString *)type {
    
    self.recordType = type;
    [self.tableView reloadData];
    
}

#pragma mark - Memory Management

- (void)dealloc {
    [account release];
    [nameTextField release];
    [typeTextField release];
    [dataTextField release];
    [super dealloc];
}

@end
