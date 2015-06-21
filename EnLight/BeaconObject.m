//
//  BeaconObject.m
//  BeaconDB
//
//  Created by Catherine Jue on 6/17/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "BeaconObject.h"

@implementation BeaconObject
- (id)init
{
    self = [super init];
    return self;
}

- (void)setCharacteristics:(NSNumber *)a withRole:(NSString *)r withUDID:(NSString *)u withColor:(NSString *)c withMajor:(NSString *)ma withMinor:(NSString *)mi
{
    self.angle = a;
    self.role = r;
    self.udid = u;
    self.color = c;
    self.major = ma;
    self.minor = mi;
}


@end
