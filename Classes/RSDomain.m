//
//  RSDomain.m
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSDomain.h"
#import "NSString+Conveniences.h"
#import "RSRecord.h"

@implementation RSDomain

@synthesize name, identifier, comment, accountId, emailAddress, updated, created, ttl, nameservers, records;

- (void)dealloc {
    [name release];
    [identifier release];
    [comment release];
    [accountId release];
    [emailAddress release];
    [updated release];
    [created release];
    [ttl release];
    [nameservers release];
    [records release];
    [super dealloc];
}

- (void)populateWithJSON:(NSDictionary *)dict {
    
    NSLog(@"json to parse: %@", dict);
    
    self.name = [dict objectForKey:@"name"];
    self.identifier = [dict objectForKey:@"id"];
    self.comment = [dict objectForKey:@"comment"];
    self.accountId = [dict objectForKey:@"accountId"];
    self.emailAddress = [dict objectForKey:@"emailAddress"];
    
    // details properties
    self.ttl = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"ttl"] intValue]];
    
    NSArray *jsonRecords = [[dict objectForKey:@"recordsList"] objectForKey:@"records"];
    
    self.records = [[[NSMutableArray alloc] initWithCapacity:[jsonRecords count]] autorelease];
    for (NSDictionary *recordDict in jsonRecords) {
        RSRecord *record = [[RSRecord alloc] init];
        [record populateWithJSON:recordDict];
        [self.records addObject:record];
        [record release];
    }

    NSArray *jsonNameservers = [dict objectForKey:@"nameservers"];
    self.nameservers = [[[NSMutableArray alloc] initWithCapacity:[jsonNameservers count]] autorelease];
    for (NSDictionary *nsDict in jsonNameservers) {
        [self.nameservers addObject:[nsDict objectForKey:@"name"]];
    }
        
    /*
     {
     "accountId":481265,"updated":"2012-04-03T05:08:39.000+0000","ttl":9999,
     "recordsList":{
     "records":[
     {"name":"overhrd1.com","id":"NS-7522580","type":"NS","data":"dns1.stabletransit.com","updated":"2012-04-03T05:08:38.000+0000","ttl":9999,"created":"2012-04-03T05:08:38.000+0000"},
     {"name":"overhrd1.com","id":"NS-7522581","type":"NS","data":"dns2.stabletransit.com","updated":"2012-04-03T05:08:39.000+0000","ttl":9999,"created":"2012-04-03T05:08:39.000+0000"}],"totalEntries":2},
     "emailAddress":"greenisus@gmail.com","created":"2012-04-03T05:08:38.000+0000",
     "nameservers":[{"name":"ns.rackspace.com"},{"name":"ns2.rackspace.com"}]
     }
     */
    
}

+ (RSDomain *)fromJSON:(NSDictionary *)dict {
    RSDomain *rsDomain = [[[RSDomain alloc] init] autorelease];
    [rsDomain populateWithJSON:dict];
    return rsDomain;
}

- (NSString *)toJSON {
    
    NSString *json
        = @"{ \"domains\" : [ {"
        "    \"name\" : \"<name>\","
        "    \"ttl\" : <ttl>,"
        "    \"emailAddress\" : \"<email>\""
        "} ] }";
    json = [json replace:@"<name>" with:self.name];
    json = [json replace:@"<ttl>" with:self.ttl];
    json = [json replace:@"<email>" with:self.emailAddress];
    return json;
    
    
    /*
{ "domains" : [ {
    "name" : "example.com",
    "comment" : "Optional domain comment...",
    "recordsList" : {
    "records" : []
    },
    "subdomains" : {
    "domains" : []
    },
    "ttl" : 3600,
    "emailAddress" : "sample@rackspace.com"
} ] }
     */
}

@end
