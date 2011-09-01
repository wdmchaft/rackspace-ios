//
//  LoadBalancerConnectionThrottle.m
//  OpenStack
//
//  Created by Mike Mayo on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerConnectionThrottle.h"
#import "NSObject+NSCoding.h"
#import "NSString+Conveniences.h"


@implementation LoadBalancerConnectionThrottle

@synthesize minConnections, maxConnections, maxConnectionRate, rateInterval;

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

+ (LoadBalancerConnectionThrottle *)fromJSON:(NSDictionary *)dict {
    LoadBalancerConnectionThrottle *t = [[[LoadBalancerConnectionThrottle alloc] init] autorelease];
    t.minConnections = [[dict objectForKey:@"minConnections"] intValue];
    t.maxConnections = [[dict objectForKey:@"maxConnections"] intValue];
    t.maxConnectionRate = [[dict objectForKey:@"maxConnectionRate"] intValue];
    t.rateInterval = [[dict objectForKey:@"rateInterval"] intValue];
    return t;
}

- (NSString *)toJSON {
    NSString *json
        = @"{ \"connectionThrottle\": { "
        "        \"minConnections\": \"<minConnections>\","
        "        \"maxConnections\": \"<maxConnections>\","
        "        \"maxConnectionRate\": \"<maxConnectionRate>\","
        "        \"rateInterval\": \"<rateInterval>\""
        "  }}";
    json = [json replace:@"<minConnections>" withInt:self.minConnections];
    json = [json replace:@"<maxConnections>" withInt:self.maxConnections];
    json = [json replace:@"<maxConnectionRate>" withInt:self.maxConnectionRate];
    json = [json replace:@"<rateInterval>" withInt:self.rateInterval];
    return json;
}

@end
