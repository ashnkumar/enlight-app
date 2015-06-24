//
//  EnLightAlgorithm.m
//  EnLight
//
//  Created by Catherine Jue on 6/21/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "EnLightAlgorithm.h"
#import "BeaconObject.h"

#define variance 5 //Set this variance for how big to make the acceptance range IN DEGREES

@interface EnLightAlgorithm ()
@end

@implementation EnLightAlgorithm

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (NSArray *)beaconMatchingHeading:(float)givenHeading
                    withCoordinates:(CGPoint)userCoordinates withBeacons:(NSArray *)beaconsArray
{
    if (userCoordinates.x && userCoordinates.y)
    {
        __block NSString *returnedBeaconColor = nil;
        
        for (BeaconObject *beacon in beaconsArray)
        {
           float beaconX = [beacon.x floatValue];
            float beaconY = [beacon.y floatValue];
            if ([self testBeaconWithColor:beacon.color
                                  beaconX:beaconX
                                  beaconY:beaconY
                              withHeading:givenHeading
                                    userX:userCoordinates.x
                                    userY:userCoordinates.y])
            {
               // NSLog(@"beacon returned %@ color", beacon.color);
                returnedBeaconColor = beacon.color;
                NSArray *result = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@", beacon.role], beacon.major, nil];
                return result;
            }
        }
        
        /*[beaconsArray enumerateObjectsUsingBlock:^(NSDictionary *beaconDic, NSUInteger idx, BOOL *stop) {
            float beaconX = [beaconDic[@"xCoord"] floatValue];
            float beaconY = [beaconDic[@"yCoord"] floatValue];
            
            if ([self testBeaconWithColor:beaconDic[@"color"]
                                  beaconX:beaconX
                                  beaconY:beaconY
                              withHeading:givenHeading
                                    userX:userCoordinates.x
                                    userY:userCoordinates.y])
            {
                returnedBeaconColor = beaconDic[@"color"];
                *stop = YES;
            }
        }];*/
    }
    
    else
    {
        NSLog(@"passed user coordinates in algorithm was not passed correctly");
        return nil;
    }
    
    return nil;
}

- (BOOL)testBeaconWithColor:(NSString *)beaconColor
                    beaconX:(float)beaconX
                    beaconY:(float)beaconY
                withHeading:(float)givenHeading
                      userX:(float)userX
                      userY:(float)userY
{
    float neededHeading;
    
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

    NSLog(@"testing beacon color: %@, given heading %f, neededheading: %f", beaconColor, givenHeading, neededHeading);
    
    if ((givenHeading >= neededHeading - variance) && (givenHeading <= neededHeading + variance))
    {
        return true;
    }
    
    return false;
}

@end
