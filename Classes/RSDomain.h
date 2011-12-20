//
//  RSDomain.h
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSDomain : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSDate *created;

+ (RSDomain *)fromJSON:(NSDictionary *)dict;

@end
