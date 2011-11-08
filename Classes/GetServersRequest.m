//
//  GetServersRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 12/24/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "GetServersRequest.h"
#import "OpenStackAccount.h"
#import "Server.h"
#import "Image.h"
#import "Flavor.h"
#import "AccountManager.h"


@implementation GetServersRequest

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	GetServersRequest *request = [[[GetServersRequest alloc] initWithURL:url] autorelease];
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
    return [GetServersRequest request:account method:method url:url];
}

+ (GetServersRequest *)request:(OpenStackAccount *)account {
    GetServersRequest *request = [GetServersRequest serversRequest:account method:@"GET" path:@"/servers/detail"];
    request.account = account;
    return request;
}

- (void)requestFinished {        
    if ([self isSuccess]) {
        
        account.servers = [NSMutableDictionary dictionaryWithDictionary:[self servers]];
        
        NSArray *keys = [account.servers allKeys];
        NSMutableDictionary *fullServers = [[NSMutableDictionary alloc] initWithCapacity:[keys count]];
        for (int i = 0; i < [keys count]; i++) {
            Server *server = [self.account.servers objectForKey:[keys objectAtIndex:i]];            
            server.image = [self.account.images objectForKey:server.imageId];
            server.flavor = [self.account.flavors objectForKey:server.flavorId];
            if (!server.image && server.imageId) {
                [self.account.manager getImage:server];
            }
            [fullServers setObject:server forKey:server.identifier];            
        }
        self.account.servers = [NSMutableDictionary dictionaryWithDictionary:fullServers];
        [fullServers release];
        [self.account persist];
        [self.account.manager notify:@"getServersSucceeded" request:self object:self.account];
    } else {
        [self.account.manager notify:@"getServersFailed" request:self object:self.account];
    }
    [super requestFinished];
}

- (void)failWithError:(NSError *)theError {
    [self.account.manager notify:@"getServersFailed" request:self object:self.account];
    [super failWithError:theError];
}


@end
