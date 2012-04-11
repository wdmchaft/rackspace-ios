//
//  RSRecord.m
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSRecord.h"

@implementation RSRecord

@synthesize name, identifier, type, data, ttl, priority, updated, created;

+ (NSArray *)recordTypes {
    return [NSArray arrayWithObjects:@"A/AAAA", @"CNAME", @"MX", @"NS", @"SRV", @"TXT", nil];
}

- (void)populateWithJSON:(NSDictionary *)dict {

    self.name = [dict objectForKey:@"name"];
    self.identifier = [dict objectForKey:@"id"];
    self.type = [dict objectForKey:@"type"];
    self.data = [dict objectForKey:@"data"];
    self.ttl = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"ttl"] intValue]];

}

- (void)dealloc {
    [name release];
    [identifier release];
    [type release];
    [data release];
    [ttl release];
    [priority release];
    [updated release];
    [created release];
    [super dealloc];
}

@end
