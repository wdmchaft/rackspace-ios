//
//  RSSFeedViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityIndicatorView;

@interface RSSFeedViewController : UITableViewController {
    BOOL requestFailed;
}

@property (nonatomic, retain) NSDictionary *feed;
@property (nonatomic, retain) NSMutableArray *feedItems;
@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;

@end
