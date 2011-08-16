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
#import "Server.h"


@implementation LoadBalancerNode

@synthesize identifier, address, port, condition, status, weight, server;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@:%@ on %@", [super description], self.address, self.port, self.server.name];
}

#pragma mark - Serialization and Copying

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

- (id)copyWithZone:(NSZone *)zone {
    LoadBalancerNode *copy = [[LoadBalancerNode allocWithZone:zone] init];
    copy.identifier = self.identifier;
    copy.address = self.address;
    copy.port = self.port;
    copy.condition = self.condition;
    copy.status = self.status;
    copy.weight = self.weight;
    copy.server = self.server;
    return copy;
}

#pragma mark - JSON

+ (LoadBalancerNode *)fromJSON:(NSDictionary *)dict {
    LoadBalancerNode *node = [[[LoadBalancerNode alloc] init] autorelease];
    node.identifier = [dict objectForKey:@"id"];
    node.address = [dict objectForKey:@"address"];
    node.condition = [dict objectForKey:@"condition"];
    node.status = [dict objectForKey:@"status"];
    node.port = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"port"] intValue]];
    node.weight = [[dict objectForKey:@"weight"] intValue];
    return node;
}

- (NSString *)toJSON {
    NSString *json = 
        @"{\"node\": {"
         "  \"address\": \"<address>\","
         "  \"port\": \"<port>\","
         "  \"condition\": \"<condition>\","
         "  \"weight\": <weight>}"
         "}";
    json = [json replace:@"<address>" with:self.address];
    json = [json replace:@"<port>" with:self.port];
    if (self.condition) {
        json = [json replace:@"<condition>" with:self.condition];
    } else {
        json = [json replace:@"<condition>" with:@"ENABLED"];
    }
    json = [json replace:@"<weight>" withInt:MAX(1, self.weight)];
    return json;
}

- (NSString *)toConditionUpdateJSON {
    NSString *json = 
        @"{\"node\": {"
        "  \"condition\": \"<condition>\","
        "  \"weight\": <weight>}"
        "}";
    json = [json replace:@"<condition>" with:self.condition];
    json = [json replace:@"<weight>" withInt:MAX(1, self.weight)];
    return json;
}

#pragma mark - Comparison

- (NSComparisonResult)compare:(LoadBalancerNode *)aNode {
    return [self.address caseInsensitiveCompare:aNode.address];
}

- (BOOL)isEqual:(LoadBalancerNode *)aNode {
    return [self.address isEqualToString:aNode.address];
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
