//
//  DNSRequest.h
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenStackRequest.h"

@class RSDomain, RSRecord;

@interface DNSRequest : OpenStackRequest

+ (DNSRequest *)getDomainsRequest:(OpenStackAccount *)account;
- (NSMutableDictionary *)domains;

+ (DNSRequest *)createDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain;

+ (DNSRequest *)getDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain;
+ (DNSRequest *)updateDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain;
+ (DNSRequest *)deleteDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain;
- (RSDomain *)domain;

+ (DNSRequest *)createRecordRequest:(OpenStackAccount *)account domain:(RSDomain *)domain record:(RSRecord *)record;

// note: you can only update data and ttl
+ (DNSRequest *)updateRecordRequest:(OpenStackAccount *)account domain:(RSDomain *)domain record:(RSRecord *)record;

+ (DNSRequest *)deleteRecordRequest:(OpenStackAccount *)account domain:(RSDomain *)domain record:(RSRecord *)record;

@end
