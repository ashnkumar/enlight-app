//
//  WandViewController.h
//  EnLight
//
//  Created by Catherine Jue on 6/20/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppConstants.h"
#import "EnLightDBManager.h"
#import "BeaconObject.h"
#import "EnLightAlgorithm.h"
#import "ESTLocation.h"
#import "ESTIndoorLocationView.h"

@interface WandViewController : UIViewController <CLLocationManagerDelegate, EnLightDBProtocol>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) ESTLocation *myLocation;
@property CLProximity lastProximity;

@property (nonatomic, strong) ESTIndoorLocationView *indoorLocationView;

@end
