//
//  RSDomain.h
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSDomain : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSString *accountId;
@property (nonatomic, retain) NSString *emailAddress;
@property (nonatomic, retain) NSDate *updated;
@property (nonatomic, retain) NSDate *created;
@property (nonatomic, retain) NSString *ttl;
@property (nonatomic, retain) NSMutableArray *nameservers;
@property (nonatomic, retain) NSMutableArray *records;

+ (RSDomain *)fromJSON:(NSDictionary *)dict;
- (NSString *)toJSON;
- (NSString *)toUpdateJSON;

@end
