//
//  AppConstants.h
//  EnLight
//
//  Created by Catherine Jue on 6/20/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppConstants : NSObject

//Colors
+ (UIColor *)enLightBlue;
+ (UIColor *)enLightBlack;
+ (UIColor *)enLightLightGrey;
+ (UIColor *)enLightWhite;
+ (UIColor *)enLightOrange;

//Font Sizes
+ (float)h1FontSize;
+ (float)h2FontSize;
+ (float)h3FontSize;
+ (float)tableViewFontSize;
+ (float)subscriptFontSize;
+ (float)buttonFontSize;

//Beacons
+ (NSDictionary *)beaconMapping;

@end
