//
//  RSRecordTypeViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSRecordTypeViewController;

@protocol RSRecordTypeViewControllerDelegate <NSObject>
@required
- (void)recordTypeViewController:(RSRecordTypeViewController *)recordTypeViewController didSelectRecordType:(NSString *)recordType;
@end

@interface RSRecordTypeViewController : UITableViewController

@property (nonatomic, retain) id<RSRecordTypeViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString *selectedRecordType;

- (id)initWithDelegate:(id)delegate;

@end
