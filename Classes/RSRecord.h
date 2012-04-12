//
//  RSRecord.h
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSRecord : NSObject

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSNumber *ttl;

// priority is only available for MX and SRV records
// max value is 65535
@property (nonatomic, retain) NSString *priority;

@property (nonatomic, retain) NSDate *updated;
@property (nonatomic, retain) NSDate *created;

- (void)populateWithJSON:(NSDictionary *)dict;

+ (NSArray *)recordTypes;

- (NSString *)toJSON;

@end
