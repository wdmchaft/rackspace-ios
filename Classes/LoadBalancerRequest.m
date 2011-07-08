//
//  LoadBalancerRequest.m
//  OpenStack
//
//  Created by Michael Mayo on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerRequest.h"
#import "OpenStackAccount.h"
#import "JSON.h"
#import "LoadBalancer.h"
#import "LoadBalancerProtocol.h"
#import "LoadBalancerUsage.h"
#import "LoadBalancerNode.h"
#import "NSString+Conveniences.h"


@implementation LoadBalancerRequest

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	LoadBalancerRequest *request = [[[LoadBalancerRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setTimeOutSeconds:40];
	return request;
}

+ (id)lbRequest:(OpenStackAccount *)account method:(NSString *)method endpoint:(NSString *)endpoint path:(NSString *)path {
//    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.json?now=%@", endpoint, path, now]];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.json", endpoint, path]];
    
    NSLog(@"Load Balancer URL: %@", url);
    
    return [LoadBalancerRequest request:account method:method url:url];
}

+ (LoadBalancerRequest *)getLoadBalancersRequest:(OpenStackAccount *)account endpoint:(NSString *)endpoint {
    return [LoadBalancerRequest lbRequest:account method:@"GET" endpoint:endpoint path:@"/loadbalancers"];
}

+ (LoadBalancerRequest *)getLoadBalancerDetailsRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint {
    NSString *path = [NSString stringWithFormat:@"/loadbalancers/%i", loadBalancer.identifier];
    return [LoadBalancerRequest lbRequest:account method:@"GET" endpoint:endpoint path:path];
}

+ (LoadBalancerRequest *)createLoadBalancerRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint {
	NSString *body = [loadBalancer toJSON];
    NSLog(@"create load balancer: %@", body);
    LoadBalancerRequest *request = [LoadBalancerRequest lbRequest:account method:@"POST" endpoint:endpoint path:@"/loadbalancers"];
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (LoadBalancerRequest *)updateLoadBalancerRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint {
    NSString *path = [NSString stringWithFormat:@"/loadbalancers/%i", loadBalancer.identifier];
	NSString *body = [loadBalancer toUpdateJSON];
    NSLog(@"update load balancer: %@", body);
    LoadBalancerRequest *request = [LoadBalancerRequest lbRequest:account method:@"PUT" endpoint:endpoint path:path];
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (LoadBalancerRequest *)deleteLoadBalancerRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint {
    NSString *path = [NSString stringWithFormat:@"/loadbalancers/%@", loadBalancer.identifier];
    return [LoadBalancerRequest lbRequest:account method:@"DELETE" endpoint:endpoint path:path];
}

+ (LoadBalancerRequest *)updateConnectionLoggingRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer {
    NSString *endpoint = [account loadBalancerEndpointForRegion:loadBalancer.region];
    NSString *path = [NSString stringWithFormat:@"/loadbalancers/%i/connectionlogging", loadBalancer.identifier];
	NSString *body = [NSString stringWithFormat:@"{ \"connectionLogging\": { \"enabled\": \"%@\" } }", loadBalancer.connectionLoggingEnabled ? @"true": @"false"];
    LoadBalancerRequest *request = [LoadBalancerRequest lbRequest:account method:@"PUT" endpoint:endpoint path:path];
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

- (NSMutableDictionary *)loadBalancers {
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [[parser objectWithString:[self responseString]] objectForKey:@"loadBalancers"];
    NSMutableDictionary *objects = [[[NSMutableDictionary alloc] initWithCapacity:[jsonObjects count]] autorelease];
    for (int i = 0; i < [jsonObjects count]; i++) {
        NSDictionary *dict = [jsonObjects objectAtIndex:i];
        LoadBalancer *loadBalancer = [LoadBalancer fromJSON:dict];
        [objects setObject:loadBalancer forKey:[NSNumber numberWithInt:loadBalancer.identifier]];
    }
    [parser release];
    return objects;
}

- (LoadBalancer *)loadBalancer {
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *json = [[parser objectWithString:[self responseString]] objectForKey:@"loadBalancer"];
    LoadBalancer *loadBalancer = [LoadBalancer fromJSON:json];
    [parser release];
    return loadBalancer;
}

+ (LoadBalancerRequest *)getLoadBalancerProtocols:(OpenStackAccount *)account endpoint:(NSString *)endpoint {
    return [LoadBalancerRequest lbRequest:account method:@"GET" endpoint:endpoint path:@"/loadbalancers/protocols"];
}

- (NSMutableArray *)protocols {
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [[parser objectWithString:[self responseString]] objectForKey:@"protocols"];
    NSMutableArray *objects = [[[NSMutableArray alloc] initWithCapacity:[jsonObjects count]] autorelease];
    for (NSDictionary *dict in jsonObjects) {
        [objects addObject:[LoadBalancerProtocol fromJSON:dict]];
    }
    [parser release];
    return objects;
}

+ (LoadBalancerRequest *)getLoadBalancerUsageRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint {
    NSString *path = [NSString stringWithFormat:@"/loadbalancers/%i/usage/current", loadBalancer.identifier];
    return [LoadBalancerRequest lbRequest:account method:@"GET" endpoint:endpoint path:path];
}

- (LoadBalancerUsage *)usage {
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [[parser objectWithString:[self responseString]] objectForKey:@"loadBalancerUsageRecords"];
    NSMutableArray *objects = [[[NSMutableArray alloc] initWithCapacity:[jsonObjects count]] autorelease];
    for (NSDictionary *dict in jsonObjects) {
        [objects addObject:[LoadBalancerUsage fromJSON:dict]];
    }
    [parser release];
    if ([objects count] > 0) {
        return [objects objectAtIndex:0];
    } else {
        return [[[LoadBalancerUsage alloc] init] autorelease];
    }
}
 
+ (LoadBalancerRequest *)addLoadBalancerNodesRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer nodes:(NSArray *)nodes endpoint:(NSString *)endpoint {
    NSString *path = [NSString stringWithFormat:@"/loadbalancers/%i/nodes", loadBalancer.identifier];
    NSString *body = @"{ \"nodes\": [ <nodes> ] }";
    NSString *nodesJSON = @"";
    for (int i = 0; i < [nodes count]; i++) {
        LoadBalancerNode *node = [nodes objectAtIndex:i];
        nodesJSON = [nodesJSON stringByAppendingString:[node toJSON]];
        if (i < [nodes count] - 1) {
            nodesJSON = [nodesJSON stringByAppendingString:@","];
        }
    }
    body = [body replace:@"<nodes>" with:nodesJSON];
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    LoadBalancerRequest *request = [LoadBalancerRequest lbRequest:account method:@"POST" endpoint:endpoint path:path];
	[request setPostBody:[NSMutableData dataWithData:data]];
    return request;
}

+ (LoadBalancerRequest *)updateLoadBalancerNodeRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer node:(LoadBalancerNode *)node endpoint:(NSString *)endpoint {
    NSString *path = [NSString stringWithFormat:@"/loadbalancers/%i/nodes/%@", loadBalancer.identifier, node.identifier];
	NSData *data = [[node toJSON] dataUsingEncoding:NSUTF8StringEncoding];
    LoadBalancerRequest *request = [LoadBalancerRequest lbRequest:account method:@"PUT" endpoint:endpoint path:path];
	[request setPostBody:[NSMutableData dataWithData:data]];
    return request;
}

+ (LoadBalancerRequest *)deleteLoadBalancerNodeRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer node:(LoadBalancerNode *)node endpoint:(NSString *)endpoint {
    NSString *path = [NSString stringWithFormat:@"/loadbalancers/%i/nodes/%@", loadBalancer.identifier, node.identifier];
    return [LoadBalancerRequest lbRequest:account method:@"DELETE" endpoint:endpoint path:path];
}

@end
