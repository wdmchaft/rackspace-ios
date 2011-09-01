//
//  LBTitleView.h
//  OpenStack
//
//  Created by Mike Mayo on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadBalancer;

@interface LBTitleView : UIView {
    LoadBalancer *loadBalancer;
    UIImageView *statusDot;
    UILabel *nameLabel;
    UILabel *connectedLabel;
    UILabel *bwInLabel;
    UILabel *bwOutLabel;
}

@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, retain) UIImageView *statusDot;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *connectedLabel;
@property (nonatomic, retain) UILabel *bwInLabel;
@property (nonatomic, retain) UILabel *bwOutLabel;

- (id)initWithLoadBalancer:(LoadBalancer *)loadBalancer;

@end
