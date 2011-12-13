//
//  DNSRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DNSRequest.h"
#import "OpenStackAccount.h"

@implementation DNSRequest

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	DNSRequest *request = [[[DNSRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setTimeOutSeconds:40];
	return request;
}

+ (id)dnsRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.json", [account dnsURL], path]];
    NSLog(@"DNS URL: %@", url);
    return [DNSRequest request:account method:method url:url];

}

+ (DNSRequest *)getDomainsRequest:(OpenStackAccount *)account {
    return [DNSRequest dnsRequest:account method:@"GET" path:@"/domains"];
}

@end
