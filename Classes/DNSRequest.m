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

+ (DNSRequest *)createDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain {
    
	NSString *body = [domain toJSON];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/domains", account.dnsURL]];
    NSLog(@"create domain: %@", body);
    DNSRequest *request = [OpenStackRequest request:account method:@"POST" url:url];    
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
    
}

+ (DNSRequest *)getDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain {
    
    NSString *path = [NSString stringWithFormat:@"/domains/%@?showRecords=true&showSubdomains=true", domain.identifier];
    return [DNSRequest dnsRequest:account method:@"GET" path:path];
    
}

- (RSDomain *)domain {
    
    /*
        {
            "name":"overhrd1.com",
            "id":3208782,
            "accountId":481265,"updated":"2012-04-03T05:08:39.000+0000","ttl":9999,
            "recordsList":{
                "records":[
                    {"name":"overhrd1.com","id":"NS-7522580","type":"NS","data":"dns1.stabletransit.com","updated":"2012-04-03T05:08:38.000+0000","ttl":9999,"created":"2012-04-03T05:08:38.000+0000"},
                    {"name":"overhrd1.com","id":"NS-7522581","type":"NS","data":"dns2.stabletransit.com","updated":"2012-04-03T05:08:39.000+0000","ttl":9999,"created":"2012-04-03T05:08:39.000+0000"}],"totalEntries":2},
            "emailAddress":"greenisus@gmail.com","created":"2012-04-03T05:08:38.000+0000",
            "nameservers":[{"name":"ns.rackspace.com"},{"name":"ns2.rackspace.com"}]
        }
    */
    
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *dict = [parser objectWithString:[self responseString]];
    RSDomain *rsDomain = [RSDomain fromJSON:dict];
    [parser release];
    return rsDomain;
    
}


@end
