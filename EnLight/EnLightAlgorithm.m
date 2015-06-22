//
//  EnLightAlgorithm.m
//  EnLight
//
//  Created by Catherine Jue on 6/21/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "EnLightAlgorithm.h"
#define variance 90 //Set this variance for how big to make the acceptance range IN DEGREES

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
    beacon1X = -5;
    beacon1Y = 0;
    
    beacon2X = 0;
    beacon2Y = 5;
    
    beacon3X = 5;
    beacon3Y = 0;
    
    beacon4X = 0;
    beacon4Y = -5;
}

- (BOOL)matchedNeededHeading:(float)givenHeading withCoordinates:(NSArray *)passedUser
{
    BOOL result = NO;
    
    if (passedUser.count == 2)
    {
        NSNumber *temp = [passedUser firstObject];
        userX = [temp floatValue];
        temp = [passedUser lastObject];
        userY = [temp floatValue];
        
        BOOL testIfHeadingsMatch = NO;
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

- (BOOL)testBeacon:(int)num withHeading:(float)givenHeading
{
    float beaconX;
    float beaconY;
    float neededHeading;
    
    //Set up beaconX, beaconY
    switch (num) {
        case 1:
        {
            beaconX = beacon1X;
            beaconY = beacon1Y;
            break;
        }
        case 2:
        {
            beaconX = beacon2X;
            beaconY = beacon2Y;
            break;
        }
        case 3:
        {
            beaconX = beacon3X;
            beaconY = beacon3Y;
            break;
        }
        case 4:
        {
            beaconX = beacon4X;
            beaconY = beacon4Y;
            break;
        }
        default:
            break;
    }
    
    //Calculate the x distance between user and beacon
    float xDistance;
    if (userX > beaconX)
        xDistance = fabsf(userX - beaconX);
    else
        xDistance = fabsf(beaconX - userX);
    
    //Calculate the y distance from user and beacon
    float yDistance;
    if (userY > beaconY)
        yDistance = fabsf(userY - beaconY);
    else
        yDistance = fabsf(beaconY - userY);
    
    //Calculate the hypotenuse
    float calcSquares = xDistance * xDistance + yDistance * yDistance;
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
    float angleOfTriangleRad = asinf(oppositeSide/hypotenuse);
    float angleOfTriangleDegrees = angleOfTriangleRad * 57.2957795;
    //Take the complementary angle
    float angleOfTriangle = 90 - angleOfTriangleDegrees;
    
    //Calculate the needed headings
    if (userX < beaconX && userY < beaconY)
    {
        //neededHeading = 90 - angleOfTriangle;
        neededHeading = angleOfTriangle;
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
    
    NSLog(@"for beacon %i, heading needed is: %f", num, neededHeading);
    
    //Final step: test if they match!!! (TODO: or are close)
    /*if ((givenHeading >= neededHeading - variance) && (givenHeading <= neededHeading + variance))
    {
        //NSLog(@"algorithm returned true for beacon %i", num);
        return true;
    }*/
    return false;
}

@end
