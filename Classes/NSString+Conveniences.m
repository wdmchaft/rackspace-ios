//
//  NSString+Conveniences.m
//  OpenStack
//
//  Created by Mike Mayo on 10/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "NSString+Conveniences.h"


@implementation NSString (Conveniences)

- (BOOL)isURL {
    return [self hasPrefix:@"http://"] || [self hasPrefix:@"https://"];
}

- (NSString *)replace:(NSString *)s with:(NSString *)r {
    return [self stringByReplacingOccurrencesOfString:s withString:r];
}

- (NSString *)replace:(NSString *)s withInt:(NSInteger)i {
    return [self replace:s with:[NSString stringWithFormat:@"%i", i]];
}

@end
