//
//  EnLightAlgorithm.m
//  EnLight
//
//  Created by Catherine Jue on 6/21/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "EnLightAlgorithm.h"
#define variance 10 //Set this variance for how big to make the acceptance range IN DEGREES

@interface EnLightAlgorithm ()
@property (nonatomic, strong) NSArray *beaconsArr;
@end

@implementation EnLightAlgorithm

- (id)init
{
    self = [super init];
    if (self)
    {
        // [AK] =============================================================
        // @TODO: This needs to come from Parse; I'm using dummy data
        // (from the ashwinLocation.json file). It corresponds to the actual
        // beacons I had from when I really did map the room
        // [AK] =============================================================
        
        _beaconsArr = @[@{@"color": @"green",
                          @"xCoord": @-0.6079069349184979,
                          @"yCoord": @2.37729769708943},
                        @{@"color": @"blue1",
                          @"xCoord": @-0.3736770133665756,
                          @"yCoord": @-1.900216953096876},
                        @{@"color": @"blue2",
                          @"xCoord": @1.104500931964482,
                          @"yCoord": @-2.17720315598735},
                        @{@"color": @"purple",
                          @"xCoord": @1.410031417741905,
                          @"yCoord": @0.7379279358198194}];
    }
    return self;
}

- (NSString *)beaconMatchingHeading:(float)givenHeading
                    withCoordinates:(CGPoint)userCoordinates
{
    if (userCoordinates.x && userCoordinates.y)
    {
        __block NSString *returnedBeaconColor = nil;
        
        [self.beaconsArr enumerateObjectsUsingBlock:^(NSDictionary *beaconDic, NSUInteger idx, BOOL *stop) {
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
        }];
        
        return returnedBeaconColor;
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
    
    if ((givenHeading >= neededHeading - variance) && (givenHeading <= neededHeading + variance))
    {
        return true;
    }
    
    return false;
}

@end
