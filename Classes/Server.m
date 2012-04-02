//
//  Server.m
//  OpenStack
//
//  Created by Mike Mayo on 10/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Server.h"
#import "Base64.h"
#import "NSObject+SBJSON.h"
#import "Flavor.h"
#import "Image.h"
#import "OpenStackAccount.h"
#import "NSObject+NSCoding.h"
#import "NSString+Conveniences.h"


@implementation Server

@synthesize progress, imageId, flavorId, status, hostId, addresses, metadata, image, flavor, urls, personality, backupSchedule, rootPassword;


// TODO: getter/setter for rootPassword should use Keychain class
// TODO: generate uuid for servers.  key password on uuid

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        [self autoDecode:coder];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Server *copy = [[Server allocWithZone:zone] init];
    copy.identifier = self.identifier;
    copy.imageId = self.imageId;
    copy.flavorId = self.flavorId;
    copy.status = self.status;
    copy.addresses = self.addresses;
    copy.image = self.image;
    copy.flavor = self.flavor;
    return copy;
}

#pragma mark - JSON

- (void)populateWithJSON:(NSDictionary *)dict {
    self.identifier = [dict objectForKey:@"id"];
    if ([dict objectForKey:@"flavorId"]) {
        self.flavorId = [[dict objectForKey:@"flavorId"] description];
    }
    if ([dict objectForKey:@"flavor"]) {
        Flavor *f = [Flavor fromJSON:[dict objectForKey:@"flavor"]];
        self.flavorId = f.identifier;
    }
    if ([dict objectForKey:@"imageId"]) {
        self.imageId = [[dict objectForKey:@"imageId"] description];
    }
    if ([dict objectForKey:@"image"]) {
        self.image = [Image fromJSON:[dict objectForKey:@"image"]];
        self.imageId = self.image.identifier;
    }
    self.addresses = [dict objectForKey:@"addresses"];
    
    if ([[self.addresses objectForKey:@"public"] isKindOfClass:[NSArray class]]) {
        
        NSMutableDictionary *newAddresses = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
        
        NSArray *publicIPs = [self.addresses objectForKey:@"public"];
        NSMutableArray *newPublicIPs = [[[NSMutableArray alloc] initWithCapacity:[publicIPs count]] autorelease];
        for (NSDictionary *ip in publicIPs) {
            if ([ip isKindOfClass:[NSDictionary class]]) {
                [newPublicIPs addObject:[ip objectForKey:@"addr"]];
            } else {
                [newPublicIPs addObject:ip];
            }
        }
        [newAddresses setObject:newPublicIPs forKey:@"public"];
        
        NSArray *privateIPs = [self.addresses objectForKey:@"private"];
        NSMutableArray *newPrivateIPs = [[[NSMutableArray alloc] initWithCapacity:[privateIPs count]] autorelease];
        for (NSDictionary *ip in privateIPs) {
            if ([ip isKindOfClass:[NSDictionary class]]) {
                [newPrivateIPs addObject:[ip objectForKey:@"addr"]];
            } else {
                [newPrivateIPs addObject:ip];
            }
        }
        [newAddresses setObject:newPrivateIPs forKey:@"private"];
        
        self.addresses = newAddresses;
    }
    
    self.status = [dict objectForKey:@"status"];
    
    if ([dict objectForKey:@"progress"]) {
        self.progress = [[dict objectForKey:@"progress"] intValue];
    }
    
    self.rootPassword = [dict objectForKey:@"adminPass"];
}

- (id)initWithJSONDict:(NSDictionary *)dict {
    self = [super initWithJSONDict:dict];
    if (self) {
        [self populateWithJSON:dict];        
    }
    return self;
}

+ (Server *)fromJSON:(NSDictionary *)dict {
    Server *server = [[[Server alloc] initWithJSONDict:dict] autorelease];
    [server populateWithJSON:dict];
    return server;
}

- (NSString *)toJSON:(NSString *)apiVersion {
    
    NSLog(@"apiVersion: %@", apiVersion);
    
    BOOL version1 = ![apiVersion isEqualToString:@"1.1"];
    
    NSString *json
        = @"{ \"server\": { "
        "        \"name\": \"<name>\","
        "        \"<flavorType>\": <flavor>,"
        "        \"<imageType>\": <image>"
        "        <metadata><personality>"
        "  }}";
    if (self.name) {
        json = [json replace:@"<name>" with:self.name];    
    } else {
        json = [json replace:@"<name>" with:@"slice"];
    }
    json = [json replace:@"<flavorType>" with:version1 ? @"flavorId" : @"flavorRef"];
    
    if (version1) {
        json = [json replace:@"<flavor>" with:self.flavorId];
    } else {
        json = [json replace:@"<flavor>" with:[NSString stringWithFormat:@"\"%@\"", self.flavorId]];
    }
    
    json = [json replace:@"<imageType>" with:version1 ? @"imageId" : @"imageRef"];

    if (version1) {
        json = [json replace:@"<image>" with:self.imageId];
    } else {
        json = [json replace:@"<image>" with:[NSString stringWithFormat:@"\"%@\"", self.imageId]];
    }
    
    if (self.metadata && [self.metadata count] > 0) {
        json = [json replace:@"<metadata>" with:[NSString stringWithFormat:@", \"metadata\": %@", [self.metadata JSONRepresentation]]];
    } else {
        json = [json replace:@"<metadata>" with:@""];
    }

    if (self.personality && [self.personality count] > 0) {
        NSString *personalityJSON = @", \"personality\": [ ";
        
        NSArray *paths = [self.personality allKeys];
        for (int i = 0; i < [paths count]; i++) {
            NSString *path = [paths objectAtIndex:i];
            personalityJSON = [personalityJSON stringByAppendingString:[NSString stringWithFormat:@"{ \"path\": \"%@\", \"contents\": \"%@\" }", path, [Base64 encode:[[self.personality objectForKey:path] dataUsingEncoding:NSUTF8StringEncoding]]]];
            if (i < [paths count] - 1) {
                personalityJSON = [personalityJSON stringByAppendingString:@", "];
            }
        }
        personalityJSON = [personalityJSON stringByAppendingString:@" ]"];
        
        json = [json replace:@"<personality>" with:personalityJSON];
        
    } else {
        json = [json replace:@"<personality>" with:@""];
    }
    
    NSLog(@"server json: %@", json);
    
    return json;
    
}

#pragma mark - Build

- (BOOL)shouldBePolled {
	return ([self.status isEqualToString:@"BUILD"] || [self.status isEqualToString:@"UNKNOWN"] || [self.status isEqualToString:@"RESIZE"] || [self.status isEqualToString:@"QUEUE_RESIZE"] || [self.status isEqualToString:@"PREP_RESIZE"] || [self.status isEqualToString:@"REBUILD"] || [self.status isEqualToString:@"REBOOT"] || [self.status isEqualToString:@"HARD_REBOOT"]);
}

#pragma mark - Setters

- (void)setFlavor:(Flavor *)aFlavor {
    if (aFlavor) {
        flavor = aFlavor;
        self.flavorId = self.flavor.identifier;
        [flavor retain];
    }
}

- (Image *)image {
    if (!image) {
        for (OpenStackAccount *account in [OpenStackAccount accounts]) {
            Image *i = [account.images objectForKey:self.imageId];
            if (i) {
                self.image = i;
                break;
            }
        }
    }
    return image;
}

- (void)setImage:(Image *)anImage {
    if (anImage) {
        image = anImage;
        self.imageId = self.image.identifier;
        [image retain];
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [status release];
    [hostId release];
    [addresses release];
    [metadata release];
    [image release];
    [flavor release];
    [urls release];
    [personality release];
    [backupSchedule release];
    [rootPassword release];
    [flavorId release];
    [imageId release];
    [super dealloc];
}

@end
