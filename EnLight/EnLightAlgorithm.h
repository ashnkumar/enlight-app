//
//  EnLightAlgorithm.h
//  EnLight
//
//  Created by Catherine Jue on 6/21/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface EnLightAlgorithm : NSObject

- (BOOL) matchedNeededHeading:(CLLocationDirection)givenHeading;

@end