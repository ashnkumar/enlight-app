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
    //Coordinates
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
        userX = 0;
        userY = 0;
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

- (void)setBeaconCoordinates
{
    
}

- (BOOL)matchedNeededHeading:(CLHeading *)givenHeading withCoordinates:(NSArray *)passedUser
{
    BOOL result;
    
    if (passedUser.count == 2)
    {
        NSNumber *temp = [passedUser firstObject];
        userX = [temp floatValue];
        temp = [passedUser lastObject];
        userY = [temp floatValue];
        
        BOOL testIfHeadingsMatch;
        for (int i = 0; i < 4; i++)
        {
            testIfHeadingsMatch = [self testBeacon:i+1 withHeading:givenHeading];
            if (testIfHeadingsMatch)
                return true;
        }
    }
    else
    {
        NSLog(@"passed user in algorithm was not passed correctly");
    }
    return result;
}

- (BOOL)testBeacon:(int)num withHeading:(CLHeading *)givenHeading
{
    float beaconX;
    float beaconY;
    float neededHeading;
    
    //Calculate the x distance between user and beacon
    float xDistance = fabsf(userX - beaconX);
    
    //Calculate the y distance from user and beacon
    float yDistance = fabsf(userY - beaconY);
    
    //Calculate the hypotenuse
    float calcSquares = xDistance * xDistance + yDistance + yDistance;
    float hypotenuse = sqrtf(calcSquares);
    
    //Calculate the angle in the triangle use angle = arcsin(opposite/hypotenuse)
    float oppositeSide;
    if (userY > beaconY)
    {
        oppositeSide = xDistance;
    }
    else
    {
        oppositeSide = yDistance;
    }
    float angleOfTriangle = asinf(oppositeSide/hypotenuse);
    
    //Calculate the needed headings
    if (userX < beaconX && userY < beaconY)
    {
        neededHeading = 90 - angleOfTriangle;
    }
    else if (userX < beaconX && userY > beaconY)
    {
        neededHeading = 180 - angleOfTriangle;
    }
    else if (userX > beaconX && userY > beaconY)
    {
        neededHeading = 270 - angleOfTriangle;
    }
    else if (userX > beaconX && userY < beaconY)
    {
        neededHeading = 360 - angleOfTriangle;
    }
    //Edge cases: userX == beaconX and/or userX == beaconY; ignore for now (beacons change so often you probably wouldn't be exactly equal ever
    
    //Final step: test if they match!!! (TODO: or are close)
    if (neededHeading == [givenHeading trueHeading])
    {
        return true;
    }
    return false;
}

@end
