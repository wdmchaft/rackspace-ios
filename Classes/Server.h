//
//  Server.h
//  OpenStack
//
//  Created by Mike Mayo on 10/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ComputeModel.h"

@class Image, Flavor, BackupSchedule;

@interface Server : ComputeModel <NSCoding, NSCopying> {
}

// progress from 0-100 for the current or last action
@property (nonatomic, assign) NSInteger progress; 

@property (nonatomic, retain) NSString *imageId;
@property (nonatomic, retain) NSString *flavorId;
@property (nonatomic, retain) NSString *status;

// unique ID for the host machine
@property (nonatomic, retain) NSString *hostId;

// "public" and "private" IP addresses
@property (nonatomic, retain) NSDictionary *addresses;

@property (nonatomic, retain) NSDictionary *metadata;
@property (nonatomic, retain) Image *image;
@property (nonatomic, retain) Flavor *flavor;

// user configured URLs that are associated with the server
@property (nonatomic, retain) NSMutableDictionary *urls;

// personality is for file injection.  keys are the path, and values are file contents
@property (nonatomic, retain) NSDictionary *personality;
@property (nonatomic, retain) BackupSchedule *backupSchedule;
@property (nonatomic, retain) NSString *rootPassword;

- (id)initWithJSONDict:(NSDictionary *)dict;
+ (Server *)fromJSON:(NSDictionary *)jsonDict;
- (NSString *)toJSON:(NSString *)apiVersion;
- (BOOL)shouldBePolled;

@end
