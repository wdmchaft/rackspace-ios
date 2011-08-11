//
//  LoadBalancer.h
//  OpenStack
//
//  Created by Mike Mayo on 2/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ComputeModel.h"
#import "ASIHTTPRequest.h"

@class LoadBalancerProtocol, LoadBalancerUsage, LoadBalancerConnectionThrottle, OpenStackAccount;

@interface LoadBalancer : ComputeModel <NSCoding> {
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

- (void)pollUntilActive:(OpenStackAccount *)account withProgress:(ASIBasicBlock)progressBlock complete:(ASIBasicBlock)completeBlock;
- (void)pollUntilActive:(OpenStackAccount *)account complete:(ASIBasicBlock)completeBlock;

- (void)pollUntilActive:(OpenStackAccount *)account delegate:(id)delegate completeSelector:(SEL)completeSelector object:(id)object;
- (void)pollUntilActive:(OpenStackAccount *)account delegate:(id)delegate progressSelector:(SEL)progressSelector completeSelector:(SEL)completeSelector object:(id)object;

- (UIImage *)imageForStatus;

@end
