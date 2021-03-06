//
//  WandViewController.m
//  EnLight
//
//  Created by Catherine Jue on 6/20/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "WandViewController.h"
#import "EnLightButton.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "ESTIndoorLocationManager.h"
#import "ESTPositionView.h"
#import "EnLightAlgorithm.h"


#define screenWidth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
#define halfOfScreenWidth [[UIScreen mainScreen] bounds].size.width/2
#define halfOfScreenHeight [[UIScreen mainScreen] bounds].size.height/2
#define lightFont @"OpenSans-Light"

@interface WandViewController () <ESTIndoorLocationManagerDelegate>

@property (strong, nonatomic)UILabel *welcomeLabel;
//@property (strong, nonatomic)UIView *building;
@property (strong, nonatomic)UIImageView *user;
//@property (strong, nonatomic)UILabel *descriptionLabel;
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@property (strong, nonatomic) EnLightDBManager *db;
@property (strong, nonatomic) NSMutableArray *beaconsInDB;
@property (strong, nonatomic) NSArray *beaconsFound;
@property (strong, nonatomic) NSString *latestLocation;
@property (assign, nonatomic) BOOL firstFlag; //Used to normalize degrees of user's caret pointer in iPhone ui
@property (assign, nonatomic) double firstHeading;
@property (assign, nonatomic) CLLocationDirection heading;

// For showing user position
@property (nonatomic, strong) ESTIndoorLocationManager *manager;
@property (nonatomic, strong) ESTLocation *location;
@property (nonatomic, strong) ESTPositionView *positionView;
@property (nonatomic, assign) CGPoint currentUserCoordinate;
@property (strong, nonatomic) UILabel *positionLabel; //Displays all information on UI (incl. errors)
@property (strong, nonatomic) EnLightAlgorithm *algoHelper;

@end

@implementation WandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [AppConstants enLightBlue];
    self.algoHelper = [[EnLightAlgorithm alloc] init];
    self.firstFlag = NO;
    self.firstHeading = 0;
    
    [self setupIndoorNavStuff];

    //Add the EnLight logo
    float logoWidth = screenWidth *.15;
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(halfOfScreenWidth-(logoWidth/2), 40, logoWidth, logoWidth)];
    [logoView setImage:[UIImage imageNamed:@"EnLightLogo"]];
    
    [self.view addSubview:logoView];

    //Description text
    float welcomeWidthStartingX = screenWidth * 0.75 / 2;
    self.welcomeLabel = [[UILabel alloc]initWithFrame:CGRectMake(halfOfScreenWidth-welcomeWidthStartingX, halfOfScreenHeight-100, welcomeWidthStartingX * 2, 200)];
    self.welcomeLabel.text = @"Your EnLight Wand is now ready for use";
    self.welcomeLabel.numberOfLines = 0;
    self.welcomeLabel.textColor = [AppConstants enLightWhite];
    [self.welcomeLabel setFont:[UIFont fontWithName:lightFont size:30.0]];
    [self.welcomeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.welcomeLabel];
    
    //Position Label
    int positionLabelWidth = screenWidth *.85;
    int positionLabelHeight = 50;
    self.positionLabel = [[UILabel alloc]initWithFrame:CGRectMake(halfOfScreenWidth-positionLabelWidth/2, screenHeight-40-positionLabelHeight, positionLabelWidth, positionLabelHeight)];
    self.positionLabel.text = @"";
    self.positionLabel.numberOfLines = 0;
    self.positionLabel.textColor = [AppConstants enLightWhite];
    [self.positionLabel setFont:[UIFont fontWithName:lightFont size:18.0]];
    [self.positionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.positionLabel];
    
    //Accessibility
    self.synthesizer = [[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Your EnLight wand is now ready for use"];
    utterance.pitchMultiplier = 1.0;
    utterance.rate = 0.1;
    [self.synthesizer speakUtterance:utterance];
    
    self.latestLocation = @"none";
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeWelcomeLabel) userInfo:nil repeats:NO];
}

- (void)setupIndoorNavStuff
{
    self.manager = [[ESTIndoorLocationManager alloc] init];
    self.manager.delegate = self;
}

- (void)removeWelcomeLabel
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.welcomeLabel.alpha = 0;
                     } completion:^(BOOL succeeded){
                         [self initializeBuilding];
                         [self addEstimotePositionView];
                     }];
}

- (void)initializeBuilding
{
    //Display the square building, 75% of screen's width
    /*float buildingSize = screenWidth * 0.75;
    float halfBuildingSize = buildingSize/2;
    self.building = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/2-halfBuildingSize, screenHeight/2-halfBuildingSize, buildingSize, buildingSize)];
    self.building.layer.borderColor = [AppConstants enLightWhite].CGColor;
    self.building.layer.borderWidth = 3.0f;
    self.building.clipsToBounds = YES;
    [self.view addSubview:self.building];

    //Draw a marker to represent the iPhone user at the bottom of the view
    float userOriginX = screenWidth/2-10;
    float userOriginY = self.building.frame.origin.y+buildingSize-50;
    self.user = [[UIImageView alloc]initWithFrame:CGRectMake(userOriginX, userOriginY, 20, 35)];
    [self.user setImage:[UIImage imageNamed:@"User"]];
    [self.view addSubview:self.user];
    
    //Insert text of what beacon you're looking at
    float descriptLabelStartingX = self.building.frame.origin.x;
    float descriptLabelStartingY = self.building.frame.origin.y + self.building.frame.size.height + 20;
    self.descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(descriptLabelStartingX, descriptLabelStartingY, self.building.frame.size.width, 30)];
    self.descriptionLabel.text = @""; //"Scanning the area" if no beacons are found
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textColor = [AppConstants enLightWhite];
    [self.descriptionLabel setFont:[UIFont fontWithName:lightFont size:20.0]];
    [self.descriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.descriptionLabel];*/
    
    //Instead, draw a caret that takes up most of the space
    float userHeight = screenWidth * .6;
    float userWidth = screenWidth * .6 * 2 / 3; //Make the dimensions of ratio 2x3
    float userOriginX = screenWidth/2-userWidth/2;
    float userOriginY = screenHeight/2-userHeight/2;
    self.user = [[UIImageView alloc]initWithFrame:CGRectMake(userOriginX, userOriginY, userWidth, userHeight)];
    [self.user setImage:[UIImage imageNamed:@"User"]];
    [self.view addSubview:self.user];
    
    /*self.indoorLocationView = [[ESTIndoorLocationView alloc] initWithFrame:self.building.frame];
    self.indoorLocationView.backgroundColor = [UIColor clearColor];
    self.indoorLocationView.transform = CGAffineTransformIdentity;
    [self.view addSubview:self.indoorLocationView];*/
    
    self.beaconsInDB = [[NSMutableArray alloc]init];
    
    self.positionLabel.text = @"Scanning the area...";
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Scanning the area"];
    
    utterance.pitchMultiplier = 1.0;
    utterance.rate = 0.1;

    [self.synthesizer speakUtterance:utterance];
    
    [self setUpConnections];
}

- (void)addEstimotePositionView
{
//    self.positionView = [[ESTPositionView alloc] initWithImage:[UIImage imageNamed:@"navigation_guy"] location:self.location forViewWithBounds:self.indoorLocationView.bounds];
//    self.indoorLocationView.positionView = self.positionView;
 //   [self.indoorLocationView drawLocation:self.myLocation]; //Cat commented this so doesn't draw the estimote beacons (positioning was off once I removed the building rectangle)
    [self.manager startIndoorLocation:self.myLocation];
}

- (void)setUpConnections
{
    self.db = [[EnLightDBManager alloc]init];
    self.db.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc]init];
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.distanceFilter = 1000;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //Set up beacons
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    NSString *beaconIdentifier = @"RegionIdentifier";
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:beaconIdentifier];
    
    [self.locationManager startMonitoringForRegion:beaconRegion];
     [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    
    [self.locationManager startUpdatingLocation];
    
    if ([CLLocationManager headingAvailable]) {
        self.locationManager.headingFilter = kCLHeadingFilterNone;
        [self.locationManager startUpdatingHeading];
    }
}

#pragma mark - normal stuff
/*- (void)sonarBoomWithHeading
{
    if (self.beaconsInDB.count > 0)
    {
        for (BeaconObject *beacon in self.beaconsInDB)
        {
            float headingAsFloat = [beacon.angle floatValue];
            float minimumOfRange = headingAsFloat - 1.0;
            float maximumOfRange = headingAsFloat + 1.0;
            
            if (self.heading >= minimumOfRange && self.heading <= maximumOfRange) {
                NSString *beaconFeetString = @"";
                NSString *locationName = beacon.role;
                
                NSString *desiredMajor = beacon.major;
                for (CLBeacon *beaconInBeaconsFound in self.beaconsFound)
                {
                    NSString *beaconFoundMajor = [NSString stringWithFormat:@"%@", beaconInBeaconsFound.major];
                    if ([desiredMajor isEqualToString:beaconFoundMajor])
                    {
                        float beaconDistanceInFeet = beaconInBeaconsFound.accuracy * 3.28084;
                        beaconFeetString = [NSString stringWithFormat:@"%.0f feet", beaconDistanceInFeet];
                    }
                    
                    if (![self.latestLocation isEqualToString:locationName]) {
                        
                        NSString *finalUtteranceString = [NSString stringWithFormat:@"The %@ is ahead", locationName];
                        if (![beaconFeetString isEqualToString:@""])
                        {
                            finalUtteranceString = [NSString stringWithFormat:@"%@ in %@", finalUtteranceString, beaconFeetString];
                        }
                        
                        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:finalUtteranceString];
                        
                        utterance.pitchMultiplier = 1.0;
                        utterance.rate = 0.1;
                        
                        self.descriptionLabel.text = finalUtteranceString;
                        
                        [self.synthesizer speakUtterance:utterance];
                        self.latestLocation = locationName;
                    }
                    return;
                }
            }
        }
    }
}*/

#pragma mark - Estimote indoor location manager

- (void)indoorLocationManager:(ESTIndoorLocationManager *)manager
            didUpdatePosition:(ESTOrientedPoint *)position
                 withAccuracy:(ESTPositionAccuracy)positionAccuracy
                   inLocation:(ESTLocation *)location
{
    /*self.positionLabel.text = [NSString stringWithFormat:@"x: %.2f  y: %.2f   α: %.2f",
                               position.x,
                               position.y,
                               position.orientation];*/
    
    self.currentUserCoordinate = CGPointMake(position.x, position.y);
    
    [self.positionView updateAccuracy:positionAccuracy];
    [self.indoorLocationView updatePosition:position];
}

- (void)indoorLocationManager:(ESTIndoorLocationManager *)manager didFailToUpdatePositionWithError:(NSError *)error
{
    self.positionView.hidden = YES;
    self.positionLabel.hidden = NO;
    
    if (error.code == ESTIndoorPositionOutsideLocationError)
    {
        self.positionLabel.text = @"There was an error getting your location.";
    }
    else if (error.code == ESTIndoorMagnetometerInitializationError)
    {
        self.positionLabel.text = @"It seems your magnetometer isn't working.";
    }
    NSLog(@"%@", error.localizedDescription);
}

#pragma mark - LocationManager
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:
(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    self.beaconsFound = beacons;
    /*NSString *message = @"";
    
    if(beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        if(nearestBeacon.proximity == self.lastProximity ||
           nearestBeacon.proximity == CLProximityUnknown) {
            return;
        }
        self.lastProximity = nearestBeacon.proximity;
        
        switch(nearestBeacon.proximity) {
            case CLProximityFar:
                message = @"You are far away from the beacon";
                break;
            case CLProximityNear:
                message = @"You are near the beacon";
                break;
            case CLProximityImmediate:
                message = @"You are in the immediate proximity of the beacon";
                break;
            case CLProximityUnknown:
                return;
        }
    } else {
        message = @"No beacons are nearby";
    }*/ //Not used
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
    return YES;
}

-(void)locationManager:(CLLocationManager *)manager
        didEnterRegion:(CLRegion *)region {
    [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager
         didExitRegion:(CLRegion *)region {
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    double degrees;
    //Normalize the heading based on the initial reading of the user's heading
    if (!self.firstFlag)
    {
        //Gvrab the heading (in degrees)
        self.firstHeading = newHeading.trueHeading;
        degrees = 0;
        self.firstFlag = YES;
    }
    else
    {
        degrees = newHeading.trueHeading - self.firstHeading;
        if (degrees >= 360)
        {
            degrees -= 360; //Reset it to 0
        }
    }
    
    double radians = degrees * M_PI / 180;
    self.user.transform = CGAffineTransformMakeRotation(radians);
    
    //Test user's heading relative to beacons
    self.heading = newHeading.trueHeading;
    
    if (self.beaconsInDB.count == 0)
    {
        //First call, get the beacons for the first time
        [self.db getBeacons];
    }
    else
    {
        [self testBeacons];
    }
}

#pragma mark - beacon managing
- (void)beaconsReturned:(NSMutableArray *)beacons
{
    self.beaconsInDB = beacons;
    [self testBeacons];
}

- (void) testBeacons
{
    if (self.currentUserCoordinate.x && self.currentUserCoordinate.y && [self.beaconsInDB count] > 0)
    {
        double headingToSend = self.heading;
        
        NSArray *returnedMatchingBeacon = [self.algoHelper beaconMatchingHeading:headingToSend withCoordinates:self.currentUserCoordinate withBeacons:self.beaconsInDB];
        
        if ([returnedMatchingBeacon count] == 2)
        {
            [self displayFoundBeacons:returnedMatchingBeacon];
        }
    }
}

//returnedMatchingBeacon holds role & major
- (void)displayFoundBeacons:(NSArray *)returnedMatchingBeacon
{
    if (![self.latestLocation isEqualToString:[returnedMatchingBeacon firstObject]])
    {
        NSString *beaconFeetString = @"";
        NSString *desiredMajor = [returnedMatchingBeacon lastObject];
        
        for (CLBeacon *beaconInBeaconsFound in self.beaconsFound)
        {
            
            NSString *beaconFoundMajor = [NSString stringWithFormat:@"%@", beaconInBeaconsFound.major];
            if ([desiredMajor isEqualToString:beaconFoundMajor])
            {
                float beaconDistanceInFeet = beaconInBeaconsFound.accuracy * 3.28084;
                if (beaconDistanceInFeet > 0) //Just in case the accuracy returns negative (happens when can't get location)
                {
                    beaconFeetString = [NSString stringWithFormat:@"in %.0f feet", beaconDistanceInFeet];
                }
            }
        }
        
        NSString *foundRole = [returnedMatchingBeacon firstObject];
        NSString *resultingString = [NSString stringWithFormat:@"The %@ is ahead %@", [foundRole lowercaseString], beaconFeetString];
        self.positionLabel.text = resultingString;
        
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:resultingString];
        utterance.pitchMultiplier = 1.0;
        utterance.rate = 0.1;
        
        [self.synthesizer speakUtterance:utterance];
        self.latestLocation = [returnedMatchingBeacon firstObject];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.manager stopIndoorLocation];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
