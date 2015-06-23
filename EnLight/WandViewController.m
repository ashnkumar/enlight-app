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
@property (strong, nonatomic)UIView *building;
@property (strong, nonatomic)UIImageView *user;
@property (strong, nonatomic)UILabel *descriptionLabel;
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@property (strong, nonatomic) EnLightDBManager *db;
@property (strong, nonatomic) NSMutableArray *beaconsInDB; //real, from DB
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
@property (strong, nonatomic) UILabel *positionLabel;
@property (strong, nonatomic) EnLightAlgorithm *algoHelper;
@property (weak, nonatomic) IBOutlet UILabel *foundBeaconLabel;

@end

@implementation WandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [AppConstants enLightBlue];
    self.algoHelper = [[EnLightAlgorithm alloc] init];
    self.firstFlag = NO;
    
    [self setupIndoorNavStuff];

    //Add the EnLight logo
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(halfOfScreenWidth-25, 40, 50, 50)];
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
    [self.positionLabel setFont:[UIFont fontWithName:lightFont size:16.0]];
    [self.positionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.positionLabel];

    //Accessibility
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
    
    // [AK] =============================================================
    //      This is where we get the indoor view to display to the user
    //      I had problems with adding the "positionView" (the guy that
    //      represents where the user is on the map) due to some CALayer
    //      errors. If we can't figure this out, let's stick with the
    //      basic version without the indoor view
    // [AK] =============================================================
    // Get position view from Estimote
    /*self.indoorLocationView = [[ESTIndoorLocationView alloc] initWithFrame:self.building.frame];
    self.indoorLocationView.backgroundColor = [UIColor clearColor];
    self.indoorLocationView.transform = CGAffineTransformIdentity;
    [self.view addSubview:self.indoorLocationView];*/
    
    //Prepare other stuff
    self.beaconsInDB = [[NSMutableArray alloc]init];
    self.synthesizer = [[AVSpeechSynthesizer alloc]init];
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
    //Setup database connection
    self.db = [[EnLightDBManager alloc]init];
    self.db.delegate = self;
    
    //Setup location manager
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
    self.positionLabel.text = [NSString stringWithFormat:@"x: %.2f  y: %.2f   α: %.2f",
                               position.x,
                               position.y,
                               position.orientation];
    
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
        self.positionLabel.text = @"It seems your magnetometer is not working.";
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"It seems your magnetometer isn't working."];
        
        utterance.pitchMultiplier = 1.0;
        utterance.rate = 0.1;
        
        [self.synthesizer speakUtterance:utterance];
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
    if (!self.firstFlag)
    {
        //grab the heading (in degrees)
        self.firstHeading = newHeading.trueHeading;
    }
    
    //TODO: Display self.user based on the user's first heading
    
    double degrees = newHeading.trueHeading;
    double radians = degrees * M_PI / 180;
    self.user.transform = CGAffineTransformMakeRotation(-radians);
    
    self.heading = newHeading.trueHeading;
    
    if (self.beaconsInDB.count == 0)
    {
        //first call, get the beacons for the first time
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
        
        // [AK] =============================================================
        //      This is where the magic happens, I am checking whenever the
        //      user's heading changes, if they are looking at a beacon
        //      and displaying that beacon to the user
        
        //      @TODO: We need to have the speech synthesizer speak out the
        //      ROLE of the beacon (right now it just displays the color,
        //      so we need to get the beaconMapping from parse somewhere and
        //      figure out what role that color corresponds to (you can add
        //      that role checking in the algorithm or elsewhere, doesn't
        //      need to be done here)
        
        // [AK] =============================================================
        
        
        NSString *returnedBeaconColor = [self.algoHelper beaconMatchingHeading:headingToSend withCoordinates:self.currentUserCoordinate withBeacons:self.beaconsInDB];
        
        if (returnedBeaconColor)
        {
            [self displayFoundBeacons:returnedBeaconColor];
        }
        
        else
        {
            self.foundBeaconLabel.text = @"";
        }
    }
}

- (void)displayFoundBeacons:(NSString *)returnedBeaconColor
{
    self.foundBeaconLabel.text = returnedBeaconColor;
    NSLog(@"did update heading returned beacon color %@", returnedBeaconColor);
    
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:returnedBeaconColor];
    
    utterance.pitchMultiplier = 1.0;
    utterance.rate = 0.1;
    
    [self.synthesizer speakUtterance:utterance];
    //figure out and say what the role is
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.manager stopIndoorLocation];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
