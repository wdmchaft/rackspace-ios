//
//  LBTitleView.m
//  OpenStack
//
//  Created by Mike Mayo on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBTitleView.h"
#import "LoadBalancer.h"
#import <QuartzCore/QuartzCore.h>


@implementation LBTitleView

@synthesize loadBalancer, nameLabel, connectedLabel, bwInLabel, bwOutLabel;

- (void)applyStyle {
    self.frame = CGRectMake(0, 0, 320, 74);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // shadow
    self.clipsToBounds = NO;
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.layer setShadowRadius:2.0f];
    [self.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.layer setShadowOpacity:0.8f];    
     
    // gradient background
    /*
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor colorWithWhite:0.871 alpha:1] CGColor], nil];
    [self.layer insertSublayer:gradient atIndex:0];   
     */
    
    // label styles
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.font = [UIFont systemFontOfSize:24];
    
    self.connectedLabel.frame = CGRectMake(8, 48, 0, 0);
    self.connectedLabel.font = [UIFont systemFontOfSize:14];
    self.connectedLabel.backgroundColor = [UIColor clearColor];
    self.connectedLabel.text = @"55 connected";
    self.connectedLabel.textColor = [UIColor darkGrayColor];
    [self.connectedLabel sizeToFit];
    [self addSubview:self.connectedLabel];
    
    self.bwInLabel.frame = CGRectMake(118, 48, 0, 0);
    self.bwInLabel.font = [UIFont systemFontOfSize:14];
    self.bwInLabel.backgroundColor = [UIColor clearColor];
    self.bwInLabel.backgroundColor = [UIColor clearColor];
    self.bwInLabel.text = @"0.55 GB in";
    self.bwInLabel.textColor = [UIColor darkGrayColor];
    [self.bwInLabel sizeToFit];
    [self addSubview:self.bwInLabel];
    
    self.bwOutLabel.frame = CGRectMake(218, 48, 0, 0);
    self.bwOutLabel.font = [UIFont systemFontOfSize:14];
    self.bwOutLabel.backgroundColor = [UIColor clearColor];
    self.bwOutLabel.backgroundColor = [UIColor clearColor];
    self.bwOutLabel.text = @"0.55 GB out";
    self.bwOutLabel.textColor = [UIColor darkGrayColor];
    [self.bwOutLabel sizeToFit];
    [self addSubview:self.bwOutLabel];
    
    // label positions
    self.nameLabel.frame = CGRectMake(32, 9, 0, 0);
    self.nameLabel.text = @"web-https1"; // self.loadBalancer.name;
    [self.nameLabel sizeToFit];
    [self addSubview:self.nameLabel];
    
}

- (id)init {
    self = [super init];
    if (self) {
        self.nameLabel = [[[UILabel alloc] init] autorelease];
        self.connectedLabel = [[[UILabel alloc] init] autorelease];
        self.bwInLabel = [[[UILabel alloc] init] autorelease];
        self.bwOutLabel = [[[UILabel alloc] init] autorelease];
        [self applyStyle];
    }
    return self;
}

- (id)initWithLoadBalancer:(LoadBalancer *)lb {
    self = [self init];
    if (self) {
        self.loadBalancer = lb;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();

    // draw gradient background
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 1.0, 0.0 };
    CGFloat components[8] = { 0.871, 0.871, 0.871, 1.0, 1.0, 1.0, 1.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, 74), 0);
    CGContextRestoreGState(context);

    UIColor *lineColor = [UIColor colorWithWhite:0.784 alpha:1];

    // draw etched lines
    [lineColor set];
    
    // horizontal line
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextSetLineWidth(context, 1.0);
	CGContextMoveToPoint(context, 0.0, 43.0);
	CGContextAddLineToPoint(context, rect.size.width, 43.0);
	CGContextStrokePath(context);
    
    // vertical lines
    float third = rect.size.width / 3.0;
    
    CGContextMoveToPoint(context, third, 43.0);
	CGContextAddLineToPoint(context, third, rect.size.height);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, third * 2, 43.0);
	CGContextAddLineToPoint(context, third * 2, rect.size.height);
    CGContextStrokePath(context);
}

- (void)dealloc {
    [loadBalancer release];
    [nameLabel release];
    [connectedLabel release];
    [bwInLabel release];
    [bwOutLabel release];
    [super dealloc];
}

@end
