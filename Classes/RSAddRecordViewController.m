//
//  RSAddRecordViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSAddRecordViewController.h"
#import "RSTextFieldCell.h"

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

@synthesize account, nameTextField, typeTextField, dataTextField;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RSRecordNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case RSRecordNameRow:
            cell.textLabel.text = @"Name";
            break;            
        case RSRecordTypeRow:
            cell.textLabel.text = @"Type";
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
