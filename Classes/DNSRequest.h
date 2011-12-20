//
//  DNSRequest.h
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenStackRequest.h"

@interface DNSRequest : OpenStackRequest

+ (DNSRequest *)getDomainsRequest:(OpenStackAccount *)account;
- (NSMutableDictionary *)domains;

@end
