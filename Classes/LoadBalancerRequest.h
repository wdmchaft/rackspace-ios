//
//  LoadBalancerRequest.h
//  OpenStack
//
//  Created by Michael Mayo on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenStackRequest.h"

@class LoadBalancerUsage, LoadBalancerNode;

@interface LoadBalancerRequest : OpenStackRequest {

}

+ (LoadBalancerRequest *)getLoadBalancersRequest:(OpenStackAccount *)account endpoint:(NSString *)endpoint;
- (NSMutableDictionary *)loadBalancers;

+ (LoadBalancerRequest *)getLoadBalancerDetailsRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint;
- (LoadBalancer *)loadBalancer;

+ (LoadBalancerRequest *)createLoadBalancerRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint;

+ (LoadBalancerRequest *)getLoadBalancerProtocols:(OpenStackAccount *)account endpoint:(NSString *)endpoint;
- (NSMutableArray *)protocols;

+ (LoadBalancerRequest *)getLoadBalancerUsageRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint;
- (LoadBalancerUsage *)usage;

+ (LoadBalancerRequest *)updateLoadBalancerNodeRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer node:(LoadBalancerNode *)node endpoint:(NSString *)endpoint;

// add nodes

+ (LoadBalancerRequest *)deleteLoadBalancerNodeRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer node:(LoadBalancerNode *)node endpoint:(NSString *)endpoint;

@end
