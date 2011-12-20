//
//  DNSRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DNSRequest.h"
#import "OpenStackAccount.h"
#import "SBJSON.h"
#import "RSDomain.h"

@implementation DNSRequest

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	DNSRequest *request = [[[DNSRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setTimeOutSeconds:40];
    
    NSLog(@"DNS request: %@", request.url);
    NSLog(@"DNS headers: %@", request.requestHeaders);
    
	return request;
}

+ (id)dnsRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [account dnsURL], path]];
    NSLog(@"DNS URL: %@", url);
    return [DNSRequest request:account method:method url:url];

}

+ (DNSRequest *)getDomainsRequest:(OpenStackAccount *)account {
    return [DNSRequest dnsRequest:account method:@"GET" path:@"/domains"];
}

- (NSMutableDictionary *)domains {
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [[parser objectWithString:[self responseString]] objectForKey:@"domains"];
    NSMutableDictionary *objects = [[[NSMutableDictionary alloc] initWithCapacity:[jsonObjects count]] autorelease];
    for (int i = 0; i < [jsonObjects count]; i++) {
        NSDictionary *dict = [jsonObjects objectAtIndex:i];
        RSDomain *rsDomain = [RSDomain fromJSON:dict];
        [objects setObject:rsDomain forKey:rsDomain.identifier];
    }
    [parser release];
    return objects;
}

@end
