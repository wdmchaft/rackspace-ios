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
#import "RSRecord.h"

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
    
	NSString *body = [NSString stringWithFormat:@"{ \"domains\" : [ %@ ] }", [domain toJSON]];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/domains", account.dnsURL]];
    NSLog(@"create domain: %@", body);
    DNSRequest *request = [OpenStackRequest request:account method:@"POST" url:url];    
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
    
}

+ (DNSRequest *)updateDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain {

	NSString *body = [domain toUpdateJSON];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/domains/%@", account.dnsURL, domain.identifier]];
    NSLog(@"update domain: %@", body);
    DNSRequest *request = [OpenStackRequest request:account method:@"PUT" url:url];
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;

}

+ (DNSRequest *)deleteDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain {
    return nil;
}

+ (DNSRequest *)getDomainRequest:(OpenStackAccount *)account domain:(RSDomain *)domain {
    
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *path = [NSString stringWithFormat:@"/domains/%@?showRecords=true&showSubdomains=true&now=%@", domain.identifier, now];
    return [DNSRequest dnsRequest:account method:@"GET" path:path];
    
}

- (RSDomain *)domain {
    
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *dict = [parser objectWithString:[self responseString]];
    RSDomain *rsDomain = [RSDomain fromJSON:dict];
    [parser release];
    return rsDomain;
    
}

+ (DNSRequest *)createRecordRequest:(OpenStackAccount *)account domain:(RSDomain *)domain record:(RSRecord *)record {
    
    NSString *json = [record toJSON];    
	NSString *body = [NSString stringWithFormat:@"{ \"records\": [ %@ ] }", json];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/domains/%@/records", account.dnsURL, domain.identifier]];
    NSLog(@"create record: %@", body);
    DNSRequest *request = [OpenStackRequest request:account method:@"POST" url:url];    
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
    
}

+ (DNSRequest *)updateRecordRequest:(OpenStackAccount *)account domain:(RSDomain *)domain record:(RSRecord *)record {
    
	NSString *body = [record toJSON];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/domains/%@/records/%@", account.dnsURL, domain.identifier, record.identifier]];
    NSLog(@"update record: %@", body);
    DNSRequest *request = [OpenStackRequest request:account method:@"PUT" url:url];
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;

}

+ (DNSRequest *)deleteRecordRequest:(OpenStackAccount *)account domain:(RSDomain *)domain record:(RSRecord *)record {

	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/domains/%@/records/%@", account.dnsURL, domain.identifier, record.identifier]];
    DNSRequest *request = [OpenStackRequest request:account method:@"DELETE" url:url];
	return request;
    
}

@end
