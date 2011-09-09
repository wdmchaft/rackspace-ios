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
    if ([r isKindOfClass:[NSString class]]) {
        return [self stringByReplacingOccurrencesOfString:s withString:r];
    } else {
        return [self stringByReplacingOccurrencesOfString:s withString:[r description]];
    }
}

- (NSString *)replace:(NSString *)s withInt:(NSInteger)i {
    return [self replace:s with:[NSString stringWithFormat:@"%i", i]];
}

@end
