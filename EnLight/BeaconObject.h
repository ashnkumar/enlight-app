//
//  BeaconObject.h
//  BeaconDB
//
//  Created by Catherine Jue on 6/17/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconObject : NSObject
@property (strong, nonatomic) NSString *macAdd;
@property (strong, nonatomic) NSString *role;
@property (strong, nonatomic) NSString *udid;
@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic) NSString *major;
@property (strong, nonatomic) NSString *minor;
@property (strong, nonatomic) NSString *x;
@property (strong, nonatomic) NSString *y;


-(void)setCharacteristics:(NSString *)macAdd withRole:(NSString *)role withUDID:(NSString *)udid withColor:(NSString *)color withMajor:(NSString *)major withMinor:(NSString *)minor withX:(NSString*)xCoord withY:(NSString *)yCoord;

@end
