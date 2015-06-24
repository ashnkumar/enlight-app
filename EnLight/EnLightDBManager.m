//
//  EnLightDBManager.m
//  BeaconDB
//
//  Created by Catherine Jue on 6/17/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "EnLightDBManager.h"
#import "BeaconObject.h"
#import <Parse/Parse.h>

@implementation EnLightDBManager

-(id) init
{
    self = [super init];
    if (self)
    {
        [Parse setApplicationId:@"7DkEQSadS72xNwLNDhgcoOcrMBFucw8IXpeygeDs" clientKey:@"HFEpgKUUtJvoG9rwjM2PLXurZkw2u1L8hcP8YKPf"];
        self.haveGottenBeaconsBefore = NO;
    }
    return self;
}

- (void)setBeacon:(NSString *)color withRole:(NSString *)role withUDID:(NSString *)udid withMajor:(NSString *)major withMinor:(NSString *)minor withX:(float)xCoord withY:(float)yCoord withMacAdd:(NSString *)mac
{
    if (mac)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
        [query whereKey:@"macAddress" equalTo:mac];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // Found
                if ([objects count] >= 1)
                {
                    PFObject *beacon = [objects firstObject];
                    if (color)
                        [beacon setObject:color forKey:@"Color"];
                    if (role)
                        [beacon setObject:role forKey:@"Role"];
                    if (udid)
                        [beacon setObject:udid forKey:@"UDID"];
                    if (major)
                        [beacon setObject:major forKey:@"Major"];
                    if (minor)
                        [beacon setObject:minor forKey:@"Minor"];
                    if(xCoord != 0) //can never be 0 because 0,0 is the center of all beacons
                        [beacon setObject:[NSString stringWithFormat:@"%f",xCoord] forKey:@"x"];
                    if (yCoord != 0)
                        [beacon setObject:[NSString stringWithFormat:@"%f",yCoord] forKey:@"y"];
                
                    [beacon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        if (!succeeded) {
                            NSLog(@"Error setting beacon to DB: %@", [error localizedDescription]);
                        }
                    }];
                }
                else
                {
                    NSLog(@"Error: DB returned 0 or more than 1 object");
                }
            
            }
            else {
                NSLog(@"Error reaching server");
            }
        }];
    }
}

- (void)simpleSetBeaconWithColor:(NSString *)color withRole:(NSString *)role
{
    PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
    [query whereKey:@"Color" equalTo:color];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Found
            if ([objects count] >= 1)
            {
                PFObject *beacon = [objects firstObject];
                //Capabilities currently only allow setting role; udid and color should remain fixed
                [beacon setObject:role forKey:@"Role"];
                [beacon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if (!succeeded) {
                        NSLog(@"Error: %@", [error localizedDescription]);
                    }
                }];
            }
            else
            {
                NSLog(@"No beacons found with that color in database!");
            }
        }
        else {
            NSLog(@"Error reaching server");
        }
    }];
    
}

- (void)getBeacons
{
    if(!self.haveGottenBeaconsBefore)
    {
        self.haveGottenBeaconsBefore = YES; //Prevent multiple calls to DB just in case it's already querying in the background
        NSMutableArray *beacons = [[NSMutableArray alloc]init];
        PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count] > 0)
            {
                for (PFObject *obj in objects)
                {
                    BeaconObject *beaconObject = [[BeaconObject alloc]init];
                    NSString *macAdd = obj[@"macAddress"];
                    NSString *role = obj[@"Role"];
                    NSString *color = obj[@"Color"];
                    NSString *udid = obj[@"UDID"];
                    NSString *major = obj[@"Major"];
                    NSString *minor = obj[@"Minor"];
                    NSString *xCoord = obj[@"x"];
                    NSString *yCoord = obj[@"y"];
                    [beaconObject setCharacteristics:macAdd withRole:role withUDID:udid withColor:color withMajor:major withMinor:minor withX:xCoord withY:yCoord];
                    [beacons addObject:beaconObject];
                }
                self.haveGottenBeaconsBefore = NO;
                [self.delegate beaconsReturned:beacons];
            }
        }];
    }
}

- (void)setAllBeaconsRoles:(NSDictionary *)configDictionary
{
    for (NSString *beaconColor in [configDictionary allKeys]) {
        [self simpleSetBeaconWithColor:beaconColor withRole:configDictionary[beaconColor]];
    }
}

@end
