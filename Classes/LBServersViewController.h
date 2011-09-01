//
//  LBServersViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer;

@interface LBServersViewController : UITableViewController {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
    NSMutableArray *serverNodes;
    NSMutableArray *originalServerNodes;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, retain) NSMutableArray *serverNodes;
@property (nonatomic, retain) NSMutableArray *originalServerNodes;

- (id)initWithAccount:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer serverNodes:(NSMutableArray *)serverNodes;

@end
