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

- (void)loadAnimation {
    NSInteger imageCount = 0;
    NSString *abbreviation = @"";
    
    if ([algorithm isEqualToString:@"Round Robin"]) {
        imageCount = 17;
        abbreviation = @"rr";
    } else if ([algorithm isEqualToString:@"Weighted Round Robin"]) {
        imageCount = 24;
        abbreviation = @"wrr";
    } else if ([algorithm isEqualToString:@"Weighted Least Connections"]) {
        imageCount = 21;
        abbreviation = @"wlc";
    } else if ([algorithm isEqualToString:@"Random"]) {
        imageCount = 17;
        abbreviation = @"random";
    } else if ([algorithm isEqualToString:@"Least Connections"]) {
        imageCount = 14;
        abbreviation = @"lc";
    }
    
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:imageCount];
    for (int i = 1; i < imageCount + 1; i++) {
        NSString *filename = [NSString stringWithFormat:@"%@-%02d_s%02d.png", abbreviation, i, i];
        [images addObject:[UIImage imageNamed:filename]];
    }
    self.imageView.animationImages = [NSArray arrayWithArray:images];
    self.imageView.animationRepeatCount = 0;
    self.imageView.animationDuration = imageCount * .4;
    [self.imageView startAnimating];
    
    [images release];
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.navigationBar.topItem.title = self.algorithm;
    [self loadAnimation];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.imageView = nil;
    self.navigationBar = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}

#pragma mark - Button Handlers

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
