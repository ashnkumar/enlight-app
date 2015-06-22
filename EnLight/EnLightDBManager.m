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
    }
    return self;
}

- (void)setBeacon:(NSString *)color withRole:(NSString *)role withUDID:(NSString *)udid withMajor:(NSString *)major withMinor:(NSString *)minor withX:(float)xCoord withY:(float)yCoord
{
    PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
    [query whereKey:@"Color" equalTo:color];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Found
            if ([objects count] >= 1)
            {
                PFObject *beacon = [objects firstObject];
                //Capabilities currently only allow setting angle and role; udid and color should remain fixed
                [beacon setObject:role forKey:@"Role"];
                [beacon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if (!succeeded) {
                        NSLog(@"Error: %@", [error localizedDescription]);
                    }
                }];
            }
            else if ([objects count] == 0)
            {
                // Make a new object
                PFObject *beacon = [PFObject objectWithClassName:@"Beacon"];
                beacon[@"Role"] = role;
                beacon[@"Color"] = color;
                if (udid)
                {
                    beacon[@"UDID"] = udid;
                }
                
                [beacon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!succeeded) {
                        NSLog(@"Error: %@", [error localizedDescription]);
                    }
                }];
            }
            else
            {
                NSLog(@"Error: database returned more than one object matching color parameters");
            }
        }
        else {
            NSLog(@"Error reaching server");
        }
    }];
}

// [AK] =============================================================
// This is to simply set the role for each beacon.
// THIS IS THE METHOD WE WANT TO CALL WHEN SETTING ROLES
// since the other factors of the beacons in Parse shouldn't change
// (i.e. we don't need to 'seed' the beacons since we can seed them
// now before sending to the judges)
// [AK] =============================================================


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
                //Capabilities currently only allow setting angle and role; udid and color should remain fixed
                [beacon setObject:role forKey:@"Role"];
                [beacon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if (!succeeded) {
                        NSLog(@"Error: %@", [error localizedDescription]);
                    }
                }];
            }
            else
            {
                NSLog(@"No baecons found with that color in database!");
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
        //TODO: insert variance in which will accept an angle as being equal
        //[query whereKey:@"Angle" equalTo:angle];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count] > 0)
            {
                for (PFObject *obj in objects)
                {
                    BeaconObject *beaconObject = [[BeaconObject alloc]init];
                    NSNumber *angle = obj[@"Angle"];
                    NSString *role = obj[@"Role"];
                    NSString *color = obj[@"Color"];
                    NSString *udid = obj[@"UDID"];
                    NSString *major = obj[@"Major"];
                    NSString *minor = obj[@"Minor"];
                    [beaconObject setCharacteristics:angle withRole:role withUDID:udid withColor:color withMajor:major withMinor:minor];
                    [beacons addObject:beaconObject];
                }
                [self.delegate beaconsReturned:beacons];
            }
        }];
    }
}

- (void)setAllBeaconsWithConfig:(NSDictionary *)configDictionary
{
    for (NSString *beaconColor in [configDictionary allKeys]) {
        [self simpleSetBeaconWithColor:beaconColor withRole:configDictionary[beaconColor]];
    }
}



@end
