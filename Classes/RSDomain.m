//
//  RSDomain.m
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSDomain.h"

@implementation RSDomain

@synthesize name, identifier, comment, accountId, emailAddress, updated, created;

- (void)dealloc {
    [name release];
    [identifier release];
    [comment release];
    [accountId release];
    [emailAddress release];
    [updated release];
    [created release];
    [super dealloc];
}

- (void)populateWithJSON:(NSDictionary *)dict {
    self.name = [dict objectForKey:@"name"];
    self.identifier = [dict objectForKey:@"id"];
    self.comment = [dict objectForKey:@"comment"];
    self.accountId = [dict objectForKey:@"accountId"];
    self.emailAddress = [dict objectForKey:@"emailAddress"];    
}

+ (RSDomain *)fromJSON:(NSDictionary *)dict {
    RSDomain *rsDomain = [[[RSDomain alloc] init] autorelease];
    [rsDomain populateWithJSON:dict];
    return rsDomain;
}

@end
