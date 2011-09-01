//
//  LoadBalancerRequest.h
//  OpenStack
//
//  Created by Michael Mayo on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenStackRequest.h"

@class LoadBalancerUsage, LoadBalancerNode, LoadBalancerConnectionThrottle;

@interface LoadBalancerRequest : OpenStackRequest {

}

+ (LoadBalancerRequest *)getLoadBalancersRequest:(OpenStackAccount *)account endpoint:(NSString *)endpoint;
- (NSMutableDictionary *)loadBalancers:(OpenStackAccount *)account;

+ (LoadBalancerRequest *)getLoadBalancerDetailsRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint;
- (LoadBalancer *)loadBalancer:(OpenStackAccount *)account;

+ (LoadBalancerRequest *)createLoadBalancerRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint;
+ (LoadBalancerRequest *)updateLoadBalancerRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint;
+ (LoadBalancerRequest *)deleteLoadBalancerRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint;

+ (LoadBalancerRequest *)updateConnectionLoggingRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer;

+ (LoadBalancerRequest *)getConnectionThrottlingRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer;
+ (LoadBalancerRequest *)updateConnectionThrottlingRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer;
+ (LoadBalancerRequest *)disableConnectionThrottlingRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer;
- (LoadBalancerConnectionThrottle *)connectionThrottle;

+ (LoadBalancerRequest *)getLoadBalancerProtocols:(OpenStackAccount *)account endpoint:(NSString *)endpoint;
- (NSMutableArray *)protocols;

+ (LoadBalancerRequest *)getLoadBalancerUsageRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint;
- (LoadBalancerUsage *)usage;

+ (LoadBalancerRequest *)addLoadBalancerNodesRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer nodes:(NSArray *)nodes endpoint:(NSString *)endpoint;
+ (LoadBalancerRequest *)updateLoadBalancerNodeRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer node:(LoadBalancerNode *)node endpoint:(NSString *)endpoint;
+ (LoadBalancerRequest *)deleteLoadBalancerNodeRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer node:(LoadBalancerNode *)node endpoint:(NSString *)endpoint;

@end
