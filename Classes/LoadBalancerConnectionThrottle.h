//
//  LoadBalancerConnectionThrottle.h
//  OpenStack
//
//  Created by Mike Mayo on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoadBalancerConnectionThrottle : NSObject <NSCoding> {
    NSInteger minConnections;
    NSInteger maxConnections;
    NSInteger maxConnectionRate;
    NSInteger rateInterval;
}

@property (assign) NSInteger minConnections;
@property (assign) NSInteger maxConnections;
@property (assign) NSInteger maxConnectionRate;
@property (assign) NSInteger rateInterval;

+ (LoadBalancerConnectionThrottle *)fromJSON:(NSDictionary *)json;
- (NSString *)toJSON;

@end
