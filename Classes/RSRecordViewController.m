//
//  RSRecordViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSRecordViewController.h"
#import "RSRecord.h"

typedef enum {
    RSRecordNameRow,
    RSRecordTypeRow,
    RSRecordDataRow,
    RSRecordMoreInfoRow,
    RSRecordNumberOfRows
} RSRecordRowType;

@interface RSRecordViewController ()

@end

@implementation RSRecordViewController

@synthesize account, domain, record;

- (id)initWithRecord:(RSRecord *)aRecord domain:(RSDomain *)aDomain account:(OpenStackAccount *)anAccount {
    
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.record = aRecord;
        self.domain = aDomain;
        self.account = anAccount;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Record";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RSRecordNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (indexPath.row == RSRecordNameRow) {
//        
//    }
//    cell.textLabel.text = @"hello";
//    cell.detailTextLabel.text = @"world";
    
    switch (indexPath.row) {
        case RSRecordNameRow:
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.record.name;
            break;            
        case RSRecordTypeRow:
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = self.record.type;
            break;            
        case RSRecordDataRow:
            cell.textLabel.text = @"Data";
            cell.detailTextLabel.text = self.record.data;
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
}

- (void)dealloc {
    [account release];
    [domain release];
    [record release];
    [super dealloc];
}

@end
