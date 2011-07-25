//
//  LoadBalancer.h
//  OpenStack
//
//  Created by Mike Mayo on 2/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ComputeModel.h"

@class LoadBalancerProtocol, LoadBalancerUsage, LoadBalancerConnectionThrottle, OpenStackAccount;

@interface LoadBalancer : ComputeModel <NSCoding> {

    LoadBalancerProtocol *protocol;
    NSString *algorithm;
    NSString *status;
    NSString *virtualIPType;
    NSMutableArray *virtualIPs;
    NSDate *created;
    NSDate *updated;
    NSUInteger maxConcurrentConnections;
    BOOL connectionLoggingEnabled;
    NSMutableArray *nodes;
//    NSMutableArray *cloudServerNodes;
    NSString *sessionPersistenceType;    
    LoadBalancerConnectionThrottle *connectionThrottle;
    NSString *clusterName;
    NSInteger progress;
    NSString *region;

    LoadBalancerUsage *usage;
}

@property (nonatomic, retain) LoadBalancerProtocol *protocol;
@property (nonatomic, retain) NSString *algorithm;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *virtualIPType;
@property (nonatomic, retain) NSMutableArray *virtualIPs;
@property (nonatomic, retain) NSDate *created;
@property (nonatomic, retain) NSDate *updated;
@property (nonatomic, assign) NSUInteger maxConcurrentConnections;
@property (nonatomic, assign) BOOL connectionLoggingEnabled;
@property (nonatomic, retain) NSMutableArray *nodes;
//@property (nonatomic, retain) NSMutableArray *cloudServerNodes;
@property (nonatomic, retain) NSString *sessionPersistenceType;  
@property (nonatomic, retain) LoadBalancerConnectionThrottle *connectionThrottle;
@property (nonatomic, retain) NSString *clusterName;
@property (nonatomic, assign) NSInteger progress;
@property (nonatomic, retain) NSString *region;
@property (nonatomic, retain) LoadBalancerUsage *usage;

+ (LoadBalancer *)fromJSON:(NSDictionary *)dict account:(OpenStackAccount *)account;
- (BOOL)shouldBePolled;
- (NSString *)toJSON;
- (NSString *)toUpdateJSON;

@end
