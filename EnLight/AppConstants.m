//
//  AppConstants.m
//  EnLight
//
//  Created by Catherine Jue on 6/20/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "AppConstants.h"

@implementation AppConstants

+ (UIColor *)enLightBlue
{
    return [UIColor colorWithRed:24.0/255.0 green: 107.0/255.0 blue:184.0/255.0 alpha:1.0f];
}

+ (UIColor *)enLightBlack
{
    return [UIColor colorWithRed:56.0/255.0 green: 56.0/255.0 blue:56.0/255.0 alpha:1.0f];
}

+ (UIColor *)enLightLightGrey
{
    return [UIColor colorWithRed:243.0/255.0 green: 243.0/255.0 blue:243.0/255.0 alpha:1.0f];
}

+ (UIColor *)enLightOrange
{
    return [UIColor colorWithRed:245.0/255.0 green: 166.0/255.0 blue:35.0/255.0 alpha:1.0f];
}

+ (UIColor *)enLightWhite
{
    return [UIColor whiteColor];
}

+ (UIColor *)estimoteDarkGreen
{
    return [UIColor colorWithRed:106.0/255.0 green: 139.0/255.0 blue:149.0/255.0 alpha:1.0f];
}

+ (float)h1FontSize
{
    return 36.0;
}

+ (float)h2FontSize
{
    return 36.0;
}

+ (float)h3FontSize
{
    return 36.0;
}

+ (float)tableViewFontSize
{
    return 36.0;
}

+ (float)buttonFontSize
{
    return 36.0;
}

+ (float)subscriptFontSize
{
    return 36.0;
}

#pragma mark - Beacons

// [AK] =============================================================
// @TODO: These are all ok, except the last value (the role) needs to be
// dynamically set based on Parse. The other values can be used since
// they will be static for the demo
// [AK] =============================================================

+ (NSDictionary *)beaconMapping
{
    return @{ @"c781b0b8375d": @[@"14173", @"purple", @"purpleBeacon", @"Exit"],
              @"ce3cf6c0e564": @[@"58724", @"green", @"greenBeacon", @"Entrance"],
              @"e2795af17586": @[@"50573", @"blue1", @"blueBeacon", @"Bathroom"],
              @"f6669ae41481": @[@"5249", @"blue2", @"blueBeacon", @"Kitchen"]
             };
}

+ (NSArray *)beaconRoleList
{
    return @[@"Restroom", @"Cashier", @"Front Door", @"Exit"];
    //return @[@"chipotle", @"chicken", @"tummy Door", @"whee"];
}

@end
