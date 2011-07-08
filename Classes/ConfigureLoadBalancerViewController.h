//
//  ConfigureLoadBalancerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer;

@interface ConfigureLoadBalancerViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
@private
    NSDictionary *algorithmNames;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer;

@end
