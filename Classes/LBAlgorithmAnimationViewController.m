//
//  LBAlgorithmAnimationViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBAlgorithmAnimationViewController.h"


@implementation LBAlgorithmAnimationViewController

@synthesize algorithm, imageView, navigationBar;

- (id)initWithAlgorithm:(NSString *)a {
    self = [super initWithNibName:@"LBAlgorithmAnimationViewController" bundle:nil];
    if (self) {
        self.algorithm = a;
    }
    return self;
}

- (void)dealloc {
    [algorithm release];
    [imageView release];
    [navigationBar release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.topItem.title = self.algorithm;

    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:17];
    for (int i = 1; i < 18; i++) {
        NSString *filename = [NSString stringWithFormat:@"rr-%02d_s%02d.png", i, i];
        [images addObject:[UIImage imageNamed:filename]];
    }
    self.imageView.animationImages = [NSArray arrayWithArray:images];
    self.imageView.animationRepeatCount = 0;
    self.imageView.animationDuration = 5;
    [self.imageView startAnimating];

    [images release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.imageView = nil;
    self.navigationBar = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Button Handlers

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
