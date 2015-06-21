//
//  BeaconObject.h
//  BeaconDB
//
//  Created by Catherine Jue on 6/17/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconObject : NSObject
@property (strong, nonatomic) NSNumber *angle;
@property (strong, nonatomic) NSString *role;
@property (strong, nonatomic) NSString *udid;
@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic) NSString *major;
@property (strong, nonatomic) NSString *minor;

-(void)setCharacteristics:(NSNumber *)angle withRole:(NSString *)role withUDID:(NSString *)udid withColor:(NSString *)color withMajor:(NSString *)major withMinor:(NSString *)minor;

@end
