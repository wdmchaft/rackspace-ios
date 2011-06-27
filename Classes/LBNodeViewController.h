//
//  LBNodeViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadBalancerNode;

@interface LBNodeViewController : UITableViewController {
    LoadBalancerNode *node;
}

@property (nonatomic, retain) LoadBalancerNode *node;

- (id)initWithNode:(LoadBalancerNode *)node;

@end
