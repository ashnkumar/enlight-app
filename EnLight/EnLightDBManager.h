//
//  EnLightDBManager.h
//  BeaconDB
//
//  Created by Catherine Jue on 6/17/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EnLightDBProtocol <NSObject>

- (void)beaconsReturned:(NSMutableArray *)beacons;

@end

@interface EnLightDBManager : NSObject
@property (nonatomic, weak) id<EnLightDBProtocol> delegate;
@property (nonatomic, assign) BOOL haveGottenBeaconsBefore;
- (void)setBeacon:(NSString *)color withRole:(NSString *)role withUDID:(NSString *)udid withMajor:(NSString *)major withMinor:(NSString *)minor withX:(float)xCoord withY:(float)yCoord withMacAdd:(NSString *)mac;

//Returns an array containing objects of type BeaconObject
- (void)getBeacons;

// Sets all beacons when merchant configures them
- (void)setAllBeaconsWithConfig:(NSDictionary *)configDictionary;

@end
