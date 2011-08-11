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

@synthesize loadBalancer, statusDot, nameLabel, connectedLabel, bwInLabel, bwOutLabel;

- (void)applyStyle {
    self.frame = CGRectMake(0, 0, 320, 74);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // shadow
    self.clipsToBounds = NO;
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.layer setShadowRadius:2.0f];
    [self.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.layer setShadowOpacity:0.8f];    
    
    // status dot
    self.statusDot.frame = CGRectMake(10, 18, 13, 13);
    self.statusDot.image = [self.loadBalancer imageForStatus];
    //self.statusDot.image = [UIImage imageNamed:@"dot-green.png"];
    [self addSubview:self.statusDot];
    
    // label styles
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.font = [UIFont systemFontOfSize:24];
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    
    CGFloat third = self.frame.size.width / 3.0;
    
    self.connectedLabel.frame = CGRectMake(0, 48, third, 20);
    self.connectedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.connectedLabel.font = [UIFont systemFontOfSize:14];
    self.connectedLabel.backgroundColor = [UIColor clearColor];
    self.connectedLabel.textAlignment = UITextAlignmentCenter;
    self.connectedLabel.text = @"";
    self.connectedLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:self.connectedLabel];
    
    self.bwInLabel.frame = CGRectMake(third, 48, third, 20);
    self.bwInLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.bwInLabel.font = [UIFont systemFontOfSize:14];
    self.bwInLabel.backgroundColor = [UIColor clearColor];
    self.bwInLabel.textAlignment = UITextAlignmentCenter;
    self.bwInLabel.text = @"";
    self.bwInLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:self.bwInLabel];
    
    self.bwOutLabel.frame = CGRectMake(third * 2, 48, third, 20);
    self.bwOutLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.bwOutLabel.font = [UIFont systemFontOfSize:14];
    self.bwOutLabel.backgroundColor = [UIColor clearColor];
    self.bwOutLabel.textAlignment = UITextAlignmentCenter;
    self.bwOutLabel.text = @"";
    self.bwOutLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:self.bwOutLabel];
    
    // label positions
    self.nameLabel.frame = CGRectMake(32, 9, 0, 0);
    self.nameLabel.text = self.loadBalancer.name;
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(32, 9, MIN(self.frame.size.width - 40, self.nameLabel.frame.size.width), self.nameLabel.frame.size.height);
    [self addSubview:self.nameLabel];
    
}

- (id)init {
    self = [super init];
    if (self) {
        self.statusDot = [[[UIImageView alloc] init] autorelease];
        self.nameLabel = [[[UILabel alloc] init] autorelease];
        self.connectedLabel = [[[UILabel alloc] init] autorelease];
        self.bwInLabel = [[[UILabel alloc] init] autorelease];
        self.bwOutLabel = [[[UILabel alloc] init] autorelease];
    }
    return self;
}

- (id)initWithLoadBalancer:(LoadBalancer *)lb {
    self = [self init];
    if (self) {
        self.loadBalancer = lb;
        [self applyStyle];
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

    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);
    
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
    
    // size labels
    self.connectedLabel.frame = CGRectMake(0, 48, third, 20);
    self.bwInLabel.frame = CGRectMake(third, 48, third, 20);
    self.bwOutLabel.frame = CGRectMake(third * 2, 48, third, 20);

}

- (void)dealloc {
    [loadBalancer release];
    [statusDot release];
    [nameLabel release];
    [connectedLabel release];
    [bwInLabel release];
    [bwOutLabel release];
    [super dealloc];
}

@end
