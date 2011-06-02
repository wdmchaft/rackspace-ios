//
//  LBAlgorithmAnimationViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadBalancer;

@interface LBAlgorithmAnimationViewController : UIViewController {
    NSString *algorithm;
    IBOutlet UIImageView *imageView;
    IBOutlet UINavigationBar *navigationBar;
}

@property (nonatomic, retain) NSString *algorithm;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

- (id)initWithAlgorithm:(NSString *)algorithm;
- (IBAction)doneButtonPressed:(id)sender;

@end
