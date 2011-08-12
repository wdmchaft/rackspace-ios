//
//  LBNodesViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer, ActivityIndicatorView;

@interface LBNodesViewController : UITableViewController <UITextFieldDelegate> {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
    BOOL isNewLoadBalancer;
    @private
    NSMutableArray *textFields;
    NSArray *previousNodes;
    NSMutableArray *ipNodes;
    NSMutableArray *cloudServerNodes;
    
    // for add/delete API calls
    NSMutableArray *nodesToDelete;
    NSInteger deleteIndex;
    NSInteger currentAPICalls;
    NSInteger totalAPICalls;
    ActivityIndicatorView *spinner;
    
    BOOL saved;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, assign) BOOL isNewLoadBalancer;

@end
