//
//  GetImagesRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 12/31/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "GetImagesRequest.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "Image.h"


@implementation GetImagesRequest

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	GetImagesRequest *request = [[[GetImagesRequest alloc] initWithURL:url] autorelease];
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
    return [GetImagesRequest request:account method:method url:url];
}

+ (GetImagesRequest *)request:(OpenStackAccount *)account {
    GetImagesRequest *request = [GetImagesRequest serversRequest:account method:@"GET" path:@"/images/detail"];
    request.account = account;
    request.validatesSecureCertificate = !account.ignoresSSLValidation;
    return request;
}

- (void)requestFinished {
    
    if ([self isSuccess]) {
        // go through results and add, rather than full replace. this way we'll keep correct OS logos
        // for servers with deprecated images
        NSMutableDictionary *newImages = [[NSMutableDictionary alloc] initWithDictionary:[self images]];
        if (!self.account.images) {
            self.account.images = [NSMutableDictionary dictionaryWithCapacity:[newImages count]];
        }
        // set them all to unlaunchable, then we'll update them
        for (Image *image in [self.account.images allValues]) {
            if ([image isKindOfClass:[Image class]]) {
                image.canBeLaunched = NO;
            }
        }
        for (Image *image in [newImages allValues]) {
            Image *newImage = [self.account.images objectForKey:image.identifier];
            if (newImage) {
                if ([newImage isKindOfClass:[Image class]]) {
                    newImage.canBeLaunched = YES;
                }
            } else {
                if ([image isKindOfClass:[Image class]]) {
                    image.canBeLaunched = YES;
                    [self.account.images setObject:image forKey:image.identifier];
                }
            }
        }
        [newImages release];
        
        [self.account persist];

    }
    
    [super requestFinished];
}

@end
