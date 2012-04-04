//
//  DNSRequest.h
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenStackRequest.h"

@class RSDomain;

@interface DNSRequest : OpenStackRequest

+ (DNSRequest *)getDomainsRequest:(OpenStackAccount *)account;
- (NSMutableDictionary *)domains;

+ (DNSRequest *)createDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain;

+ (DNSRequest *)getDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain;
- (RSDomain *)domain;

@end
