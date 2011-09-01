//
//  LoadBalancerUsage.m
//  OpenStack
//
//  Created by Michael Mayo on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerUsage.h"
#import "NSObject+NSCoding.h"


@implementation LoadBalancerUsage

@synthesize identifier, averageNumConnections, incomingTransfer, outgoingTransfer, numVips, numPolls, startTime, endTime;

#pragma mark - Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        [self autoDecode:coder];
    }
    
    return self;
}

#pragma mark - JSON

+ (LoadBalancerUsage *)fromJSON:(NSDictionary *)dict {
    LoadBalancerUsage *u = [[[LoadBalancerUsage alloc] init] autorelease];
    u.identifier = [dict objectForKey:@"id"];
    u.averageNumConnections = [[dict objectForKey:@"averageNumConnections"] doubleValue];
    u.incomingTransfer = [[dict objectForKey:@"incomingTransfer"] longLongValue];
    u.outgoingTransfer = [[dict objectForKey:@"outgoingTransfer"] longLongValue];
    u.numVips = [[dict objectForKey:@"numVips"] intValue];
    u.numPolls = [[dict objectForKey:@"numPolls"] intValue];
    return u;
}

#pragma mark - Memory Management

- (void)dealloc {
    [identifier release];
    [startTime release];
    [endTime release];
    [super dealloc];
}

@end
