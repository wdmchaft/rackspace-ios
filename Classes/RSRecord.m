//
//  RSRecord.m
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSRecord.h"

@implementation RSRecord

@synthesize name, id, type, data, ttl, updated, created;

- (void)populateWithJSON:(NSDictionary *)dict {

    self.name = [dict objectForKey:@"name"];
    self.id = [dict objectForKey:@"id"];
    self.type = [dict objectForKey:@"type"];
    self.data = [dict objectForKey:@"data"];
    self.ttl = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"ttl"] intValue]];

}

@end
