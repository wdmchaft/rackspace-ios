//
//  GetFlavorsRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 12/31/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "GetFlavorsRequest.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "Flavor.h"

@implementation GetFlavorsRequest

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	GetFlavorsRequest *request = [[[GetFlavorsRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setTimeOutSeconds:40];
    request.validatesSecureCertificate = !account.ignoresSSLValidation;
	return request;
}

+ (id)serversRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?now=%@", account.serversURL, path, now]];
    return [GetFlavorsRequest request:account method:method url:url];
}

+ (GetFlavorsRequest *)request:(OpenStackAccount *)account {
    GetFlavorsRequest *request = [GetFlavorsRequest serversRequest:account method:@"GET" path:@"/flavors/detail"];
    request.account = account;
    return request;
}


- (void)requestFinished { 

    if ([self isSuccess]) {
        self.account.flavors = [self flavors];
        [self.account persist];
    }
    
    [super requestFinished];
}

@end
