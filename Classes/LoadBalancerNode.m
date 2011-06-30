//
//  LoadBalancerNode.m
//  OpenStack
//
//  Created by Michael Mayo on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerNode.h"
#import "NSObject+NSCoding.h"
#import "NSString+Conveniences.h"


@implementation LoadBalancerNode

@synthesize identifier, address, port, condition, status, weight;

#pragma mark - Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [self autoDecode:coder];
    }
    return self;
}

#pragma mark - JSON

+ (LoadBalancerNode *)fromJSON:(NSDictionary *)dict {
    LoadBalancerNode *node = [[[LoadBalancerNode alloc] init] autorelease];
    node.identifier = [dict objectForKey:@"id"];
    node.address = [dict objectForKey:@"address"];
    node.condition = [dict objectForKey:@"condition"];
    node.status = [dict objectForKey:@"status"];
    node.port = [dict objectForKey:@"port"];
    node.weight = [[dict objectForKey:@"weight"] intValue];
    return node;
}

- (NSString *)toJSON {
    NSString *json = 
        @"{\"node\": {"
         "  \"condition\": \"<condition>\","
         "  \"weight\": <weight>}"
         "}";
    json = [json replace:@"<condition>" with:self.condition];
    json = [json replace:@"<weight>" withInt:MAX(1, self.weight)];
    return json;
}

#pragma mark - Memory Management

- (void)dealloc {
    [identifier release];
    [address release];
    [port release];
    [condition release];
    [status release];
    [super dealloc];
}

@end
