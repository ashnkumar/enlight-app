//
//  EnLightAlgorithm.h
//  EnLight
//
//  Created by Catherine Jue on 6/21/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface EnLightAlgorithm : NSObject

- (NSString *)beaconMatchingHeading:(float)givenHeading
                    withCoordinates:(CGPoint)userCoordinates;

@end
