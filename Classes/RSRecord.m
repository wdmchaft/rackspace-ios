//
//  RSRecord.m
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSRecord.h"
#import "NSString+Conveniences.h"

@implementation RSRecord

@synthesize name, identifier, type, data, ttl, priority, updated, created;

+ (NSArray *)recordTypes {
    return [NSArray arrayWithObjects:@"A", @"CNAME", @"MX", @"NS", @"SRV", @"TXT", nil];
}

- (void)populateWithJSON:(NSDictionary *)dict {

    self.name = [dict objectForKey:@"name"];
    self.identifier = [dict objectForKey:@"id"];
    self.type = [dict objectForKey:@"type"];
    self.data = [dict objectForKey:@"data"];
    self.ttl = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"ttl"] intValue]];

}

- (NSString *)toJSON {
    
    NSString *json
        = @"{  \"name\" : \"<name>\","
            "  \"type\" : \"<type>\","
            "  \"data\" : \"<data>\","
            "  \"ttl\" : <ttl>"
            "  <priority>"
            "}";
    json = [json replace:@"<name>" with:self.name];
    json = [json replace:@"<type>" with:self.type];
    json = [json replace:@"<data>" with:self.data];
    json = [json replace:@"<ttl>" with:[NSString stringWithFormat:@"%i", [self.ttl intValue]]];
    
    NSString *priorityString = @"";
    if (self.priority) {
        priorityString = [NSString stringWithFormat:@", \"priority\" : %@", self.priority];
    }
    json = [json replace:@"<priority>" with:priorityString];
    
    return json;
    
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
