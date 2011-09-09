//
//  Flavor.m
//  OpenStack
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Flavor.h"
#import "NSObject+NSCoding.h"


@implementation Flavor

@synthesize ram, disk;

#pragma mark - Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        [self autoDecode:coder];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Flavor *copy = [[Flavor allocWithZone:zone] init];
    copy.identifier = self.identifier;
    copy.ram = self.ram;
    copy.disk = self.disk;
    return copy;
}


#pragma mark - JSON

+ (Flavor *)fromJSON:(NSDictionary *)dict {
    Flavor *flavor = [[[Flavor alloc] initWithJSONDict:dict] autorelease];
    flavor.ram = [[dict objectForKey:@"ram"] intValue];
    flavor.disk = [[dict objectForKey:@"disk"] intValue];
    
    return flavor;
}

#pragma mark - Comparison

// flavors should be sorted by RAM instead of name
- (NSComparisonResult)compare:(Flavor *)aFlavor {
    return [[NSNumber numberWithInt:self.ram] compare:[NSNumber numberWithInt:aFlavor.ram]];
}


@end
