//
//  RSRecord.h
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSRecord : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSNumber *ttl;
@property (nonatomic, strong) NSString *priority;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSDate *created;

- (void)populateWithJSON:(NSDictionary *)dict;

@end
