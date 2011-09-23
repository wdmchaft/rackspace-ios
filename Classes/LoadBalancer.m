//
//  LoadBalancer.m
//  OpenStack
//
//  Created by Michael Mayo on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancer.h"
#import "VirtualIP.h"
#import "LoadBalancerNode.h"
#import "NSObject+NSCoding.h"
#import "LoadBalancerProtocol.h"
#import "LoadBalancerConnectionThrottle.h"
#import "Server.h"
#import "NSString+Conveniences.h"
#import "OpenStackAccount.h"
#import "ASIHTTPRequest.h"
#import "LoadBalancerRequest.h"


@implementation LoadBalancer

@synthesize protocol, algorithm, status, virtualIPs, created, updated, maxConcurrentConnections,
            connectionLoggingEnabled, nodes, connectionThrottle, clusterName, sessionPersistenceType, progress,
            virtualIPType, region, usage;
//@synthesize cloudServerNodes;

#pragma mark - Constructors and Memory Management

- (id)init {
    self = [super init];
    if (self) {
        self.nodes = [[[NSMutableArray alloc] init] autorelease];
//        self.cloudServerNodes = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc {
    [protocol release];
    [algorithm release];
    [status release];
    [virtualIPs release];
    [created release];
    [updated release];
    [nodes release];
    [sessionPersistenceType release];
    [clusterName release];
//    [cloudServerNodes release];
    [virtualIPType release];
    [region release];
    [usage release];
    [connectionThrottle release];
    [super dealloc];
}

#pragma mark - Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];    
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self autoDecode:coder];
    }
    return self;
}

#pragma mark - JSON

+ (LoadBalancer *)fromJSON:(NSDictionary *)dict account:(OpenStackAccount *)account {
    
    LoadBalancer *loadBalancer = [[[LoadBalancer alloc] initWithJSONDict:dict] autorelease];
    
    LoadBalancerProtocol *p = [[[LoadBalancerProtocol alloc] init] autorelease];
    p.name = [dict objectForKey:@"protocol"];
    p.port = [[dict objectForKey:@"port"] intValue];
    loadBalancer.protocol = p;
    
    loadBalancer.algorithm = [dict objectForKey:@"algorithm"];
    loadBalancer.status = [dict objectForKey:@"status"];
    
    NSArray *virtualIpDicts = [dict objectForKey:@"virtualIps"];
    loadBalancer.virtualIPs = [[[NSMutableArray alloc] initWithCapacity:[virtualIpDicts count]] autorelease];
    for (NSDictionary *vipDict in virtualIpDicts) {
        VirtualIP *ip = [VirtualIP fromJSON:vipDict];
        [loadBalancer.virtualIPs addObject:ip];
        loadBalancer.virtualIPType = ip.type;
    }
    
    loadBalancer.created = [loadBalancer dateForKey:@"time" inDict:[dict objectForKey:@"created"]];
    loadBalancer.updated = [loadBalancer dateForKey:@"time" inDict:[dict objectForKey:@"updated"]];

    if ([dict objectForKey:@"connectionLogging"]) {
        loadBalancer.connectionLoggingEnabled = [[[dict objectForKey:@"connectionLogging"] objectForKey:@"enabled"] boolValue];
    }

    NSArray *nodeDicts = [dict objectForKey:@"nodes"];
    loadBalancer.nodes = [[[NSMutableArray alloc] initWithCapacity:[nodeDicts count]] autorelease];
    for (NSDictionary *nodeDict in nodeDicts) {
        LoadBalancerNode *node = [LoadBalancerNode fromJSON:nodeDict];        
        Server *server = [account.serversByPublicIP objectForKey:node.address];
        if (server) {
            node.server = server;
        }
        [loadBalancer.nodes addObject:node];        
    }

    if ([dict objectForKey:@"connectionThrottle"]) {
        loadBalancer.connectionThrottle = [LoadBalancerConnectionThrottle fromJSON:[dict objectForKey:@"connectionThrottle"]];
    }
    
    loadBalancer.sessionPersistenceType = [[dict objectForKey:@"sessionPersistence"] objectForKey:@"persistenceType"];
    loadBalancer.clusterName = [[dict objectForKey:@"cluster"] objectForKey:@"name"];
    return loadBalancer;
}

- (NSString *)toUpdateJSON {
    NSString *json
        = @"{ \"loadBalancer\": { "
           "        \"name\": \"<name>\","
           "        \"algorithm\": \"<algorithm>\","
           "        \"protocol\": \"<protocol>\","
           "        \"port\": \"<port>\""
           "  }}";
    json = [json replace:@"<name>" with:self.name];
    json = [json replace:@"<algorithm>" with:self.algorithm];
    json = [json replace:@"<protocol>" with:self.protocol.name];
    json = [json replace:@"<port>" withInt:self.protocol.port];
    return json;
}

- (NSString *)toJSON {
    
    NSString *json = @"{ \"loadBalancer\": { ";

    json = [json stringByAppendingString:[NSString stringWithFormat:@"\"name\": \"%@\", ", self.name]];
    json = [json stringByAppendingString:[NSString stringWithFormat:@"\"protocol\": \"%@\", ", self.protocol.name]];
    json = [json stringByAppendingString:[NSString stringWithFormat:@"\"port\": \"%i\", ", self.protocol.port]];
    json = [json stringByAppendingString:[NSString stringWithFormat:@"\"algorithm\": \"%@\", ", self.algorithm]];
    
    // virtualIPType
    if ([self.virtualIPType isEqualToString:@"Public"]) {
        json = [json stringByAppendingString:@"\"virtualIps\": [ { \"type\": \"PUBLIC\" } ], "];
    } else if ([self.virtualIPType isEqualToString:@"ServiceNet"]) {
        json = [json stringByAppendingString:@"\"virtualIps\": [ { \"type\": \"SERVICENET\" } ], "];
    } else if ([self.virtualIPType isEqualToString:@"Shared Virtual IP"]) {
        //json = [json stringByAppendingString:@"\"virtualIps\": [ { \"type\": \"PUBLIC\" } ], "];
        json = [json stringByAppendingString:@"\"virtualIps\": [ "];
        for (int i = 0; i < [self.virtualIPs count]; i++) {
            VirtualIP *vip = [self.virtualIPs objectAtIndex:i];
            json = [json stringByAppendingFormat:@"{ \"id\": \"%@\" }", vip.identifier];
            if (i < [self.virtualIPs count] - 1) {
                json = [json stringByAppendingString:@","];
            }
        }
        json = [json stringByAppendingString:@"], "];
    }
    
    json = [json stringByAppendingString:@"\"nodes\": ["];
    for (int i = 0; i < [self.nodes count]; i++) {
        LoadBalancerNode *node = [self.nodes objectAtIndex:i];
        if (node.server) {
            Server *server = node.server;
            json = [json stringByAppendingString:@"{"];        
            json = [json stringByAppendingString:[NSString stringWithFormat:@"\"address\": \"%@\",", [[server.addresses objectForKey:@"public"] objectAtIndex:0]]];
            json = [json stringByAppendingString:[NSString stringWithFormat:@"\"port\": \"%i\",", self.protocol.port]];
            json = [json stringByAppendingString:@"\"condition\": \"ENABLED\""];
        } else {
            LoadBalancerNode *lbNode = node;
            json = [json stringByAppendingString:@"{"];
            json = [json stringByAppendingString:[NSString stringWithFormat:@"\"address\": \"%@\",", lbNode.address]];
            json = [json stringByAppendingString:[NSString stringWithFormat:@"\"port\": \"%@\",", lbNode.port]];
            json = [json stringByAppendingString:[NSString stringWithFormat:@"\"condition\": \"%@\"", lbNode.condition]];
        }
        
        if (i == [self.nodes count] - 1) {
            json = [json stringByAppendingString:@"}"];
        } else {
            json = [json stringByAppendingString:@"}, "];
        }
    }
    /*
    for (int i = 0; i < [self.cloudServerNodes count]; i++) {
        Server *server = [self.cloudServerNodes objectAtIndex:i];
        json = [json stringByAppendingString:@"{"];        
        json = [json stringByAppendingString:[NSString stringWithFormat:@"\"address\": \"%@\",", [[server.addresses objectForKey:@"public"] objectAtIndex:0]]];
        json = [json stringByAppendingString:[NSString stringWithFormat:@"\"port\": \"%i\",", self.protocol.port]];
        json = [json stringByAppendingString:@"\"condition\": \"ENABLED\""];
        json = [json stringByAppendingString:i == [self.cloudServerNodes count] - 1 ? @"}" : @"}, "];
    }
     */
    json = [json stringByAppendingString:@"]"];
    
    json = [json stringByAppendingString:@"}}"];
    return json;
}

- (BOOL)shouldBePolled {
    return ![self.status isEqualToString:@"ACTIVE"];
}

- (void)pollUntilActive:(OpenStackAccount *)account delegate:(id)delegate progressSelector:(SEL)progressSelector completeSelector:(SEL)completeSelector object:(id)object {
    
    NSLog(@"polling.  lb status = %@", self.status);
    
    
    if ([self shouldBePolled]) {
        NSString *endpoint = [account loadBalancerEndpointForRegion:self.region];
        __block LoadBalancerRequest *request = [LoadBalancerRequest getLoadBalancerDetailsRequest:account loadBalancer:self endpoint:endpoint];
        request.delegate = self;
        [request setCompletionBlock:^{
            if ([request isSuccess]) {
                
                LoadBalancer *newLB = [request loadBalancer:account];                
                self.status = newLB.status;
                self.progress = newLB.progress;
                // load LB stuff                
                
                NSLog(@"lb poll status: %@", self.status);
                
                if ([self shouldBePolled]) {
                    if (progressSelector && [delegate respondsToSelector:progressSelector]) {
                        [delegate performSelector:progressSelector];
                    }
                    [self pollUntilActive:account delegate:delegate progressSelector:progressSelector completeSelector:completeSelector object:object];
                } else {
                    if ([delegate respondsToSelector:completeSelector]) {
                        [delegate performSelector:completeSelector withObject:object];
                    }
                }
            }
        }];
        [request setFailedBlock:^{
            [self pollUntilActive:account delegate:delegate progressSelector:progressSelector completeSelector:completeSelector object:object];
        }];
        [request startAsynchronous];
    } else {
        if ([delegate respondsToSelector:completeSelector]) {
            [delegate performSelector:completeSelector withObject:object];
        }
    }
}

- (void)pollUntilActive:(OpenStackAccount *)account delegate:(id)delegate completeSelector:(SEL)completeSelector object:(id)object {
    [self pollUntilActive:account delegate:delegate progressSelector:nil completeSelector:completeSelector object:object];
}

- (void)pollUntilActive:(OpenStackAccount *)account withProgress:(ASIBasicBlock)progressBlock complete:(ASIBasicBlock)completeBlock {
    
    if ([self shouldBePolled]) {
        NSString *endpoint = [account loadBalancerEndpointForRegion:self.region];
        __block LoadBalancerRequest *request = [LoadBalancerRequest getLoadBalancerDetailsRequest:account loadBalancer:self endpoint:endpoint];
        request.delegate = self;
        [request setCompletionBlock:^{
            if ([request isSuccess]) {
                
                LoadBalancer *newLB = [request loadBalancer:account];                
                self.status = newLB.status;
                self.progress = newLB.progress;
                // load LB stuff                
                
                NSLog(@"lb poll status: %@", self.status);
                
                if ([self shouldBePolled]) {
                    if (progressBlock) {
                        progressBlock();
                    }
                    [self pollUntilActive:account withProgress:nil complete:completeBlock];
                } else {
                    completeBlock();
                }
            }
        }];
        [request setFailedBlock:^{
            //[progressBlock retain];
            //[completeBlock retain];
            [self pollUntilActive:account withProgress:progressBlock complete:^{ 
                completeBlock();
            }];

        }];
        [request startAsynchronous];
    } else {
        completeBlock();
    }
}

- (void)pollUntilActive:(OpenStackAccount *)account complete:(ASIBasicBlock)completeBlock {
//    [self pollUntilActive:account withProgress:nil complete:[[completeBlock copy] autorelease]];
    [self pollUntilActive:account withProgress:nil complete:completeBlock];
}

- (UIImage *)imageForStatus {
    // load balancer statuses:
    // ACTIVE    BUILD    PENDING_UPDATE    PENDING_DELETE    SUSPENDED    ERROR    DELETED
    if ([self.status isEqualToString:@"ACTIVE"]) {
        return [UIImage imageNamed:@"dot-green.png"];
    } else if ([self.status isEqualToString:@"BUILD"] || [self.status isEqualToString:@"PENDING_UPDATE"]) {
        return [UIImage imageNamed:@"dot-orange.png"];
    } else {
        return [UIImage imageNamed:@"dot-red.png"];
    }
}

@end
