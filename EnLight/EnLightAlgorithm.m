//
//  EnLightAlgorithm.m
//  EnLight
//
//  Created by Catherine Jue on 6/21/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "EnLightAlgorithm.h"

@implementation EnLightAlgorithm
{
    float userX;
    float userY;
    float beacon1X;
    float beacon1Y;
    
    float beacon2X;
    float beacon2Y;
    
    float beacon3X;
    float beacon3Y;
    
    float beacon4X;
    float beacon4Y;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //Initialize the beacons
        beacon1X = 0;
        beacon2X = 0;
        beacon3X = 0;
        beacon4X = 0;
        beacon1Y = 0;
        beacon2Y = 0;
        beacon3Y = 0;
        beacon4Y = 0;
    }
    return self;
}

- (BOOL)matchedNeededHeading:(CLLocationDirection)givenHeading
{
    BOOL result;
    
    
    
    return result;
}
@end
