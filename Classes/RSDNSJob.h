//
//  RSDNSJob.h
//  OpenStack
//
//  Created by Mike Mayo on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSDNSJob : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *jobId;
@property (nonatomic, strong) NSString *callbackUrl;

@end
