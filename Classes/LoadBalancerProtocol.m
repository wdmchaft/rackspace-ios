//
//  LoadBalancerProtocol.m
//  OpenStack
//
//  Created by Michael Mayo on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerProtocol.h"
#import "NSObject+NSCoding.h"


@implementation LoadBalancerProtocol

@synthesize name, port;

#pragma mark - Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [self autoDecode:coder];
    }
    return self;
}

#pragma mark - Memory Management

- (void)dealloc {
    [name release];
    [super dealloc];
}

#pragma mark - JSON

+ (LoadBalancerProtocol *)fromJSON:(NSDictionary *)dict {
    LoadBalancerProtocol *protocol = [[[LoadBalancerProtocol alloc] init] autorelease];
    protocol.name = [dict objectForKey:@"name"];
    protocol.port = [[dict objectForKey:@"port"] intValue];
    return protocol;
}

@end
