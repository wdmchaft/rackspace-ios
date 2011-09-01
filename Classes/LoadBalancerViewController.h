//
//  LoadBalancerViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenStackViewController.h"

@class LoadBalancer, LBTitleView, OpenStackAccount;

@interface LoadBalancerViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, UIScrollViewDelegate> {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
    LBTitleView *titleView;
    CGPoint previousScrollPoint;
    NSInteger mode;

    IBOutlet UITableView *tableView;
    
    @private
    NSMutableDictionary *nodes;
    NSInteger totalSections;
    NSInteger enabledSection;
    NSInteger disabledSection;
    NSInteger drainingSection;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, retain) LBTitleView *titleView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;


-(id)initWithLoadBalancer:(LoadBalancer *)loadBalancer;

@end
