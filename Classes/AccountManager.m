//
//  AccountManager.m
//  OpenStack
//
//  Created by Mike Mayo on 10/21/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AccountManager.h"
#import "OpenStackAccount.h"
#import "OpenStackRequest.h"
#import "Server.h"
#import "Provider.h"
#import "Image.h"
#import "Container.h"
#import "Folder.h"
#import "StorageObject.h"
#import "GetServersRequest.h"
#import "GetContainersRequest.h"
#import "GetObjectsRequest.h"
#import "GetImagesRequest.h"
#import "ASINetworkQueue.h"
#import "UpdateCDNContainerRequest.h"
#import "GetFlavorsRequest.h"
#import "LoadBalancer.h"
#import "LoadBalancerRequest.h"
#import "APICallback.h"
#import "Analytics.h"


@implementation AccountManager

@synthesize account, queue;

#pragma mark - Callbacks

- (APICallback *)callbackWithRequest:(id)request success:(APIResponseBlock)success failure:(APIResponseBlock)failure {
    APICallback *callback = [[[APICallback alloc] initWithAccount:self.account request:request] autorelease];
    ((OpenStackRequest *)request).delegate = self;
    ((OpenStackRequest *)request).callback = callback;    
    [request setCompletionBlock:^{
        if ([request isSuccess]) {
            success(request);
            [request notify];
        } else {
            failure(request);
            [request notify];
        }
    }];
    [request setFailedBlock:^{
        failure(request);
        [request notify];
    }];
    [request startAsynchronous];    
    return callback;
}

- (APICallback *)callbackWithRequest:(id)request success:(APIResponseBlock)success {
    return [self callbackWithRequest:request success:success failure:^(OpenStackRequest *request){}];
}

- (APICallback *)callbackWithRequest:(id)request {
    return [self callbackWithRequest:request success:^(OpenStackRequest *request){} failure:^(OpenStackRequest *request){}];
}

#pragma mark - Notification

- (NSString *)notificationName:(NSString *)key identifier:(NSString *)identifier {
    return [NSString stringWithFormat:@"%@-%@-%i", key, self.account.uuid, identifier];
}

- (void)requestFinished:(OpenStackRequest *)request {
    NSString *notificationName = [request.userInfo objectForKey:@"notificationName"];
    id notificationObject = [request.userInfo objectForKey:@"notificationObject"];
    
    if ([request isSuccess]) {
        NSNotification *notification = [NSNotification notificationWithName:[NSString stringWithFormat:@"%@Succeeded", notificationName] object:notificationObject];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:[NSString stringWithFormat:@"%@Failed", notificationName] object:notificationObject userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)requestFailed:(OpenStackRequest *)request {
    NSString *notificationName = [request.userInfo objectForKey:@"notificationName"];
    id notificationObject = [request.userInfo objectForKey:@"notificationObject"];
    NSNotification *notification = [NSNotification notificationWithName:[NSString stringWithFormat:@"%@Failed", notificationName] object:notificationObject userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)sendRequest:(OpenStackRequest *)request name:(NSString *)name object:(id)notificationObject {
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, notificationObject, nil] forKeys:[NSArray arrayWithObjects:@"notificationName", @"notificationObject", nil]];
    [request startAsynchronous];
}

- (void)notify:(NSString *)name request:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:name object:nil userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)notify:(NSString *)name request:(OpenStackRequest *)request object:(id)object {
    NSNotification *notification = [NSNotification notificationWithName:name object:object userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - API Calls

#pragma mark Get Limits

- (APICallback *)getLimits {
    APICallback *callback = nil;
    
    if (self.account.serversURL) {
        
        __block OpenStackRequest *request = [OpenStackRequest getLimitsRequest:self.account];
        callback = [self callbackWithRequest:request success:^(OpenStackRequest *request) {

            if ([request limits]) {
                self.account.rateLimits = [request rateLimits];
                [self.account persist];
            }
            
        }];
        
    }
    return callback;
}

#pragma mark Reboot Server

- (APICallback *)softRebootServer:(Server *)server {
    TrackEvent(CATEGORY_SERVER, EVENT_REBOOTED);
    
    __block OpenStackRequest *request = [OpenStackRequest softRebootServerRequest:self.account server:server];
    return [self callbackWithRequest:request];
}

- (APICallback *)hardRebootServer:(Server *)server {
    TrackEvent(CATEGORY_SERVER, EVENT_REBOOTED);
    
    __block OpenStackRequest *request = [OpenStackRequest hardRebootServerRequest:self.account server:server];
    return [self callbackWithRequest:request];
}

#pragma mark Change Admin Password

- (APICallback *)changeAdminPassword:(Server *)server password:(NSString *)password {
    TrackEvent(CATEGORY_SERVER, EVENT_PASSWORD_CHANGED);
    
    __block OpenStackRequest *request = [OpenStackRequest changeServerAdminPasswordRequest:self.account server:server password:password];
    return [self callbackWithRequest:request];
}

#pragma mark Rename Server

- (APICallback *)renameServer:(Server *)server name:(NSString *)name {
    TrackEvent(CATEGORY_SERVER, EVENT_RENAMED);
    
    __block OpenStackRequest *request = [OpenStackRequest renameServerRequest:self.account server:server name:name];
    return [self callbackWithRequest:request];
}

#pragma mark Delete Server

- (APICallback *)deleteServer:(Server *)server {
    TrackEvent(CATEGORY_SERVER, EVENT_DELETED);
    
    __block OpenStackRequest *request = [OpenStackRequest deleteServerRequest:self.account server:server];
    return [self callbackWithRequest:request];
}

#pragma mark Create Server

- (APICallback *)createServer:(Server *)server {
    TrackEvent(CATEGORY_SERVER, EVENT_CREATED);
    
    __block OpenStackRequest *request = [OpenStackRequest createServerRequest:self.account server:server];
    return [self callbackWithRequest:request];
}

#pragma mark Resize Server

- (APICallback *)resizeServer:(Server *)server flavor:(Flavor *)flavor {
    TrackEvent(CATEGORY_SERVER, EVENT_RESIZED);
    
    __block OpenStackRequest *request = [OpenStackRequest resizeServerRequest:self.account server:server flavor:flavor];
    return [self callbackWithRequest:request];
}

- (APICallback *)confirmResizeServer:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest confirmResizeServerRequest:self.account server:server];
    return [self callbackWithRequest:request];
}

- (APICallback *)revertResizeServer:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest revertResizeServerRequest:self.account server:server];
    return [self callbackWithRequest:request];
}

- (APICallback *)rebuildServer:(Server *)server image:(Image *)image {
    TrackEvent(CATEGORY_SERVER, EVENT_REBUILT);
    
    __block OpenStackRequest *request = [OpenStackRequest rebuildServerRequest:self.account server:server image:image];
    return [self callbackWithRequest:request];
}

- (APICallback *)getBackupSchedule:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest getBackupScheduleRequest:self.account server:server];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
        server.backupSchedule = [request backupSchedule];
    }];
}

- (APICallback *)updateBackupSchedule:(Server *)server {
    TrackEvent(CATEGORY_SERVER, EVENT_BACKUP_SCHEDULE_CHANGED);
    
    __block OpenStackRequest *request = [OpenStackRequest updateBackupScheduleRequest:self.account server:server];
    return [self callbackWithRequest:request];
}

#pragma mark Get Image

- (APICallback *)getImage:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest getImageRequest:self.account imageId:server.imageId];    
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {

        Image *image = [request image];
        if ([image isKindOfClass:[Image class]]) {
            image.canBeLaunched = NO;
            [self.account.images setObject:image forKey:image.identifier];        
            [self.account persist];        
        }
        
    }];
    
}

#pragma mark Get Servers

- (APICallback *)getServers {
    __block OpenStackRequest *request = [OpenStackRequest serversRequest:self.account method:@"GET" path:@"/servers/detail"];
    return [self callbackWithRequest:request];
}


#pragma mark Get Flavors

- (APICallback *)getFlavors {
    APICallback *callback = nil;
    if (self.account.serversURL) {
        GetFlavorsRequest *request = [GetFlavorsRequest request:self.account];
        callback = [self callbackWithRequest:request];
    }
    return callback;
}

#pragma mark Get Images

- (APICallback *)getImages {
    APICallback *callback = nil;
    if (self.account.serversURL) {
        GetImagesRequest *request = [GetImagesRequest request:self.account];
        callback = [self callbackWithRequest:request];
    }
    return callback;
}

#pragma mark - Object Storage

- (APICallback *)getContainers {
    __block OpenStackRequest *request = [OpenStackRequest filesRequest:self.account method:@"GET" path:@""];
    return [self callbackWithRequest:request];    
}

- (void)createContainer:(Container *)container {
    TrackEvent(CATEGORY_CONTAINERS, EVENT_CREATED);
    
    OpenStackRequest *request = [OpenStackRequest createContainerRequest:self.account container:container];
    request.delegate = self;
    request.didFinishSelector = @selector(createContainerSucceeded:);
    request.didFailSelector = @selector(createContainerFailed:);
    request.userInfo = [NSDictionary dictionaryWithObject:container forKey:@"container"];
    [request startAsynchronous];
}

- (void)createContainerSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {        
        Container *container = [request.userInfo objectForKey:@"container"];
        [self.account.containers setObject:container forKey:container.name];        
        [self.account persist];
        self.account.containerCount = [self.account.containers count];
        [self notify:@"createContainerSucceeded" request:request object:self.account];
    } else {
        [self notify:@"createContainerFailed" request:request object:self.account];
    }
}

- (void)createContainerFailed:(OpenStackRequest *)request {
    [self notify:@"createContainerFailed" request:request object:self.account];
}

- (void)deleteContainer:(Container *)container {
    TrackEvent(CATEGORY_CONTAINERS, EVENT_DELETED);
    
    OpenStackRequest *request = [OpenStackRequest deleteContainerRequest:self.account container:container];
    request.delegate = self;
    request.didFinishSelector = @selector(deleteContainerSucceeded:);
    request.didFailSelector = @selector(deleteContainerFailed:);
    request.userInfo = [NSDictionary dictionaryWithObject:container forKey:@"container"];
    [request startAsynchronous];
}

- (void)deleteContainerSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess] || [request responseStatusCode] == 404) {
        Container *container = [request.userInfo objectForKey:@"container"];
        [self.account.containers setObject:container forKey:container.name];                
        [self.account persist];        
        [self notify:@"deleteContainerSucceeded" request:request object:self.account];
        [self notify:@"deleteContainerSucceeded" request:request object:[request.userInfo objectForKey:@"container"]];
    } else {
        [self notify:@"deleteContainerFailed" request:request object:self.account];
        [self notify:@"deleteContainerFailed" request:request object:[request.userInfo objectForKey:@"container"]];
    }
}

- (void)deleteContainerFailed:(OpenStackRequest *)request {
    [self notify:@"deleteContainerFailed" request:request object:self.account];
    [self notify:@"deleteContainerFailed" request:request object:[request.userInfo objectForKey:@"container"]];
}

- (APICallback *)getObjects:(Container *)container {
    __block GetObjectsRequest *request = [GetObjectsRequest request:self.account container:container];
    return [self callbackWithRequest:request];
}

- (void)updateCDNContainer:(Container *)container {
    TrackEvent(CATEGORY_CONTAINERS, EVENT_UPDATED);
    
    if (![self queue]) {
        [self setQueue:[[[ASINetworkQueue alloc] init] autorelease]];
    }
    UpdateCDNContainerRequest *request = [UpdateCDNContainerRequest request:self.account container:container];
    [queue addOperation:request];
}

- (void)getObjectsSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {
        Container *container = [request.userInfo objectForKey:@"container"];
        NSMutableDictionary *objects = [request objects];
        container.rootFolder = [Folder folder];
        container.rootFolder.objects = objects;
        [self.account persist];

        NSNotification *notification = [NSNotification notificationWithName:@"getObjectsSucceeded" object:self.account userInfo:[NSDictionary dictionaryWithObject:container forKey:@"container"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"getObjectsFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)getObjectsFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"getObjectsFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)getObject:(Container *)container object:(StorageObject *)object downloadProgressDelegate:(id)downloadProgressDelegate {
    OpenStackRequest *request = [OpenStackRequest getObjectRequest:self.account container:container object:object];
    request.delegate = self;
    request.downloadProgressDelegate = downloadProgressDelegate;
    request.showAccurateProgress = YES;    
    request.didFinishSelector = @selector(getObjectSucceeded:);
    request.didFailSelector = @selector(getObjectFailed:);
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:container, object, nil] forKeys:[NSArray arrayWithObjects:@"container", @"object", nil]];
    [request startAsynchronous];
}

- (void)getObjectSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {
        Container *container = [request.userInfo objectForKey:@"container"];
        StorageObject *object = [request.userInfo objectForKey:@"object"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];        
        NSString *shortPath = [NSString stringWithFormat:@"/%@/%@", container.name, object.fullPath];
        NSString *filePath = [documentsDirectory stringByAppendingString:shortPath];
        NSString *directoryPath = [filePath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@", object.name] withString:@""];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSData *data = [request responseData];
            if ([data writeToFile:filePath atomically:YES]) {
                NSNotification *notification = [NSNotification notificationWithName:@"getObjectSucceeded" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            } else {
                NSNotification *notification = [NSNotification notificationWithName:@"getObjectFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        } else {
            NSNotification *notification = [NSNotification notificationWithName:@"getObjectFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"getObjectFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)getObjectFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"getObjectFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)writeObject:(Container *)container object:(StorageObject *)object downloadProgressDelegate:(id)downloadProgressDelegate {
    TrackEvent(CATEGORY_FILES, EVENT_CREATED);
    
    OpenStackRequest *request = [OpenStackRequest writeObjectRequest:self.account container:container object:object];
    request.delegate = self;
    request.didFinishSelector = @selector(writeObjectSucceeded:);
    request.didFailSelector = @selector(writeObjectFailed:);
    request.uploadProgressDelegate = downloadProgressDelegate;
    request.showAccurateProgress = YES;
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:container, object, nil] forKeys:[NSArray arrayWithObjects:@"container", @"object", nil]];
    [request startAsynchronous];
}

- (void)writeObjectSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {
        NSNotification *notification = [NSNotification notificationWithName:@"writeObjectSucceeded" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"writeObjectFailed" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)writeObjectFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"writeObjectFailed" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)writeObjectMetadata:(Container *)container object:(StorageObject *)object {
    OpenStackRequest *request = [OpenStackRequest writeObjectMetadataRequest:self.account container:container object:object];
    request.delegate = self;
    request.didFinishSelector = @selector(writeObjectMetadataSucceeded:);
    request.didFailSelector = @selector(writeObjectMetadataFailed:);
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:container, object, nil] forKeys:[NSArray arrayWithObjects:@"container", @"object", nil]];
    [request startAsynchronous];
}

- (void)writeObjectMetadataSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"getObjectsFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)writeObjectMetadataFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"writeObjectMetadataFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (APICallback *)deleteObject:(Container *)container object:(StorageObject *)object {
    TrackEvent(CATEGORY_FILES, EVENT_DELETED);
    
    OpenStackRequest *request = [OpenStackRequest deleteObjectRequest:self.account container:container object:object];
    request.delegate = self;
    request.didFinishSelector = @selector(deleteObjectSucceeded:);
    request.didFailSelector = @selector(deleteObjectFailed:);
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:container, object, nil] forKeys:[NSArray arrayWithObjects:@"container", @"object", nil]];
    
    return [self callbackWithRequest:request];
}

- (void)deleteObjectSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess] || [request responseStatusCode] == 404) {
        NSNotification *notification = [NSNotification notificationWithName:@"deleteObjectSucceeded" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"deleteObjectFailed" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)deleteObjectFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"deleteObjectFailed" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - Load Balancing

- (APICallback *)getLoadBalancers:(NSString *)endpoint {
    __block LoadBalancerRequest *request = [LoadBalancerRequest getLoadBalancersRequest:self.account endpoint:endpoint];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
        if (!self.account.loadBalancers) {
            self.account.loadBalancers = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
        }
        
        NSMutableDictionary *lbs = [(LoadBalancerRequest *)request loadBalancers:self.account];
        
        for (NSString *identifier in lbs) {
            LoadBalancer *lb = [lbs objectForKey:identifier];
            lb.region = [self.account loadBalancerRegionForEndpoint:endpoint];
        }
        
        [self.account.loadBalancers setObject:lbs forKey:endpoint];
        [self.account persist];
    }];
}

- (APICallback *)getLoadBalancerDetails:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint {
    __block LoadBalancerRequest *request = [LoadBalancerRequest getLoadBalancerDetailsRequest:self.account loadBalancer:loadBalancer endpoint:endpoint];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {

        LoadBalancer *newLB = [(LoadBalancerRequest *)request loadBalancer:self.account];
        loadBalancer.status = newLB.status;
        loadBalancer.nodes = newLB.nodes;
        loadBalancer.connectionLoggingEnabled = newLB.connectionLoggingEnabled;
        
        [self.account persist];
    }];
}

- (APICallback *)getLoadBalancerProtocols:(NSString *)endpoint {
    __block LoadBalancerRequest *request = [LoadBalancerRequest getLoadBalancerProtocols:self.account endpoint:endpoint];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
        self.account.lbProtocols = [(LoadBalancerRequest *)request protocols];
    }];
}

- (APICallback *)createLoadBalancer:(LoadBalancer *)loadBalancer {
    TrackEvent(CATEGORY_LOAD_BALANCER, EVENT_CREATED);
    
    NSString *endpoint = @"";
    
    for (NSString *url in [self.account loadBalancerURLs]) {
        if ([url hasPrefix:[NSString stringWithFormat:@"https://%@", [loadBalancer.region lowercaseString]]]) {
            endpoint = url;
            break;
        }
    }
    
    __block LoadBalancerRequest *request = [LoadBalancerRequest createLoadBalancerRequest:self.account loadBalancer:loadBalancer endpoint:endpoint];
    return [self callbackWithRequest:request];
}

- (APICallback *)updateLoadBalancer:(LoadBalancer *)loadBalancer {
    TrackEvent(CATEGORY_LOAD_BALANCER, EVENT_UPDATED);
    NSString *endpoint = [self.account loadBalancerEndpointForRegion:loadBalancer.region];
    __block LoadBalancerRequest *request = [LoadBalancerRequest updateLoadBalancerRequest:self.account loadBalancer:loadBalancer endpoint:endpoint];
    return [self callbackWithRequest:request];
}

- (APICallback *)deleteLoadBalancer:(LoadBalancer *)loadBalancer {
    TrackEvent(CATEGORY_LOAD_BALANCER, EVENT_DELETED);
    NSString *endpoint = [self.account loadBalancerEndpointForRegion:loadBalancer.region];
    __block LoadBalancerRequest *request = [LoadBalancerRequest deleteLoadBalancerRequest:self.account loadBalancer:loadBalancer endpoint:endpoint];
    return [self callbackWithRequest:request];
}

- (APICallback *)updateLoadBalancerConnectionLogging:(LoadBalancer *)loadBalancer {
    TrackEvent(CATEGORY_LOAD_BALANCER, EVENT_UPDATED_LB_CONNECTION_LOGGING);
    __block LoadBalancerRequest *request = [LoadBalancerRequest updateConnectionLoggingRequest:self.account loadBalancer:loadBalancer];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
    } failure:^(OpenStackRequest *request) {
        loadBalancer.connectionLoggingEnabled = !loadBalancer.connectionLoggingEnabled;
    }];
}

- (APICallback *)getLoadBalancerConnectionThrottling:(LoadBalancer *)loadBalancer {
    __block LoadBalancerRequest *request = [LoadBalancerRequest getConnectionThrottlingRequest:self.account loadBalancer:loadBalancer];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
        loadBalancer.connectionThrottle = [(LoadBalancerRequest *)request connectionThrottle];
    }];
}

- (APICallback *)updateLoadBalancerConnectionThrottling:(LoadBalancer *)loadBalancer {
    TrackEvent(CATEGORY_LOAD_BALANCER, EVENT_UPDATED_LB_CONNECTION_THROTTLING);
    __block LoadBalancerRequest *request = [LoadBalancerRequest updateConnectionThrottlingRequest:self.account loadBalancer:loadBalancer];
    return [self callbackWithRequest:request];
}

- (APICallback *)deleteLoadBalancerConnectionThrottling:(LoadBalancer *)loadBalancer {
    TrackEvent(CATEGORY_LOAD_BALANCER, EVENT_DISABLED_LB_CONNECTION_THROTTLING);
    __block LoadBalancerRequest *request = [LoadBalancerRequest disableConnectionThrottlingRequest:self.account loadBalancer:loadBalancer];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
        loadBalancer.connectionThrottle = nil;
    }];
}

- (APICallback *)getLoadBalancerUsage:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint {
    __block LoadBalancerRequest *request = [LoadBalancerRequest getLoadBalancerUsageRequest:self.account loadBalancer:loadBalancer endpoint:endpoint];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
        loadBalancer.usage = [(LoadBalancerRequest *)request usage];
    }];
}

- (APICallback *)addLBNodes:(NSArray *)nodes loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint {
    TrackEvent(CATEGORY_LOAD_BALANCER, EVENT_ADDED_LB_NODES);
    __block LoadBalancerRequest *request = [LoadBalancerRequest addLoadBalancerNodesRequest:self.account loadBalancer:loadBalancer nodes:nodes endpoint:endpoint];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
        for (LoadBalancerNode *node in nodes) {
            [loadBalancer.nodes addObject:node];
        }
        [self.account persist];
    }];
}

- (APICallback *)updateLBNode:(LoadBalancerNode *)node loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint {
    TrackEvent(CATEGORY_LOAD_BALANCER, EVENT_UPDATED_LB_NODE);
    __block LoadBalancerRequest *request = [LoadBalancerRequest updateLoadBalancerNodeRequest:self.account loadBalancer:loadBalancer node:node endpoint:endpoint];
    return [self callbackWithRequest:request];
}

- (APICallback *)deleteLBNode:(LoadBalancerNode *)node loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint {
    TrackEvent(CATEGORY_LOAD_BALANCER, EVENT_DELETED_LB_NODE);
    __block LoadBalancerRequest *request = [LoadBalancerRequest deleteLoadBalancerNodeRequest:self.account loadBalancer:loadBalancer node:node endpoint:endpoint];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
        [loadBalancer.nodes removeObject:node];
    }];
}

- (APICallback *)authenticate {
    __block OpenStackRequest *request = [OpenStackRequest authenticationRequest:self.account];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
        if ([request isSuccess]) {        
            self.account.authToken = [[request responseHeaders] objectForKey:@"X-Auth-Token"];
            self.account.serversURL = [NSURL URLWithString:[[request responseHeaders] objectForKey:@"X-Server-Management-Url"]];
            self.account.filesURL = [NSURL URLWithString:[[request responseHeaders] objectForKey:@"X-Storage-Url"]];
            self.account.cdnURL = [NSURL URLWithString:[[request responseHeaders] objectForKey:@"X-Cdn-Management-Url"]];
            
            [self.account persist];
        }
    }];
}

#pragma mark - Memory Management

- (void)dealloc {
    [queue release];
    [super dealloc];
}

@end
