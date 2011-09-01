//
//  LoadBalancerProtocol.h
//  OpenStack
//
//  Created by Michael Mayo on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoadBalancerProtocol : NSObject <NSCoding> {
    NSString *name;
    NSInteger port;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSInteger port;

+ (LoadBalancerProtocol *)fromJSON:(NSDictionary *)dict;

@end
