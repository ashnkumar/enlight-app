//
//  EnlightEstimoteViewController.m
//  EnLight
//
//  Created by Ashwin Kumar on 6/21/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "EnlightEstimoteViewController.h"

#import "ESTIndoorLocationManager.h"
#import "ESTConfig.h"
#import "ESTLocationBuilder.h"
#import "AppConstants.h"
#import "EnLightDBManager.h"
#import "BeaconObject.h"
#import "WandViewController.h"
#import "EnLightButton.h"
#import <AVFoundation/AVFoundation.h>

#define screenWidth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
#define halfOfScreenWidth [[UIScreen mainScreen] bounds].size.width/2
#define halfOfScreenHeight [[UIScreen mainScreen] bounds].size.height/2
#define lightFont @"OpenSans-Light"

#define TLEstimoteAppID @"enlight"
#define TLEstimoteAppToken @"0bc9e8569d2de758ce7700942af03190"
const float beaconButtonImageWidth = 30.0;
const float beaconButtonImageHeight = 38.0;

@interface EnlightEstimoteViewController () <EnLightDBProtocol, UIActionSheetDelegate>

// buttons representing beacons on screen
@property (nonatomic, strong) UIButton *beacon1Button;
@property (nonatomic, strong) UIButton *beacon2Button;
@property (nonatomic, strong) UIButton *beacon3Button;
@property (nonatomic, strong) UIButton *beacon4Button;

// Beacons, in order going counter clockwise starting with bottom beacon
@property (nonatomic, strong) NSString *beacon1Color;
@property (nonatomic, strong) NSString *beacon2Color;
@property (nonatomic, strong) NSString *beacon3Color;
@property (nonatomic, strong) NSString *beacon4Color;

// beacon role labels
@property (strong, nonatomic) UILabel *beacon1RoleLabel;
@property (strong, nonatomic) UILabel *beacon2RoleLabel;
@property (strong, nonatomic) UILabel *beacon3RoleLabel;
@property (strong, nonatomic) UILabel *beacon4RoleLabel;

// other
@property (strong, nonatomic) EnLightDBManager *db;
@property (weak, nonatomic) IBOutlet UIView *roomViewRectangle;
@property (strong, nonatomic) ESTLocation *myLocation;
@property (strong, nonatomic) EnLightButton *doneButton;
@property (strong, nonatomic) UILabel *pleaseSelectRolesLabel;

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@end

@implementation EnlightEstimoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.db = [[EnLightDBManager alloc]init];
    self.db.delegate = self;
    
    
    //Set up view
    //White rectangle at bottom of the screen
    UIView *whiteTextRect = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - 125, screenWidth, 125)];
    whiteTextRect.backgroundColor = [AppConstants enLightWhite];
    [self.view addSubview:whiteTextRect];
    
    //Instructions inside white rectangle
    int selectRolesLabelWidth = screenWidth * .75;
    int selectRolesLabelHeight = 80;
    self.pleaseSelectRolesLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - selectRolesLabelWidth/2, whiteTextRect.frame.size.height/2 - selectRolesLabelHeight/2, selectRolesLabelWidth, selectRolesLabelHeight)];
    self.pleaseSelectRolesLabel.text = @"Almost there! Let’s assign roles to each of the beacons. Tap each beacon and select its role from the menu provided.";
    self.pleaseSelectRolesLabel.numberOfLines = 0;
    [self.pleaseSelectRolesLabel setTextColor:[AppConstants enLightBlack]];
    [self.pleaseSelectRolesLabel setFont:[UIFont fontWithName:lightFont size:16.0]];
    [self.pleaseSelectRolesLabel setTextAlignment:NSTextAlignmentCenter];
    [whiteTextRect addSubview:self.pleaseSelectRolesLabel];
    
    //Finish button
    int doneButtonWidth = selectRolesLabelWidth;
    int doneButtonHeight = 44;
    self.doneButton = [[EnLightButton alloc]init];
    [self.doneButton setUp:CGRectMake(screenWidth/2 - doneButtonWidth/2, screenHeight - whiteTextRect.frame.size.height/2 - doneButtonHeight/2, doneButtonWidth, doneButtonHeight)];
    [self.doneButton setBackgroundColor:[AppConstants enLightBlue]];
    [self.doneButton setTitle:@"Finish" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(doneConfiguringBeacons) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneButton];
    
    //Simulated nav bar
    int navBarHeight = screenHeight*.12;
    UIView *navbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, navBarHeight)];
    [navbar setBackgroundColor:[AppConstants estimoteDarkGreen]];
    [self.view addSubview:navbar];
    
    //Navbar's logo
    int logoWidth = 45;
    UIImageView *navbarLogo = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth/2-logoWidth/2, navBarHeight-10-logoWidth, logoWidth, logoWidth)];
    [navbarLogo setImage:[UIImage imageNamed:@"estimoteDarkGreenLogo"]];
    [navbar addSubview:navbarLogo];
    
    //Beacon labels -- assign them positions once have beacon coordinates
    self.beacon1RoleLabel = [[UILabel alloc]init];
    [self.beacon1RoleLabel setFrame:CGRectMake(0, 0, 30, 10)];
    [self.view addSubview:self.beacon1RoleLabel];
    
    self.beacon2RoleLabel = [[UILabel alloc]init];
    [self.beacon1RoleLabel setFrame:CGRectMake(0, 0, 30, 10)];
    [self.view addSubview:self.beacon1RoleLabel];
    
    self.beacon3RoleLabel = [[UILabel alloc]init];
    [self.beacon1RoleLabel setFrame:CGRectMake(0, 0, 30, 10)];
    [self.view addSubview:self.beacon1RoleLabel];
    
    self.beacon4RoleLabel = [[UILabel alloc]init];
    [self.beacon1RoleLabel setFrame:CGRectMake(0, 0, 30, 10)];
    [self.view addSubview:self.beacon1RoleLabel];
    
    [self hideUnhideBeaconLabels:YES];
    
    //Accessibility
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Almost there! Let’s assign roles to each of the beacons. Tap each beacon and select its role from the menu provided."];
    
    utterance.pitchMultiplier = 1.0;
    utterance.rate = 0.1;
    
    [self.synthesizer speakUtterance:utterance];


    // [AK] =============================================================
    // Logic to hide/show button/label based on if all beacons have
    // been setup. See '(void)checkIfRolesAreAllAssigned' method below
    // [AK] =============================================================
    self.doneButton.hidden = YES;
    self.pleaseSelectRolesLabel.hidden = NO;
    
    [self authorizeEnlight];
}

- (void)hideUnhideBeaconLabels:(BOOL)hide
{
    if (hide)
    {
        self.beacon1RoleLabel.hidden = YES;
        self.beacon2RoleLabel.hidden = YES;
        self.beacon3RoleLabel.hidden = YES;
        self.beacon4RoleLabel.hidden = YES;
    }
    else if (!hide)
    {
        self.beacon1RoleLabel.hidden = NO;
        self.beacon2RoleLabel.hidden = NO;
        self.beacon3RoleLabel.hidden = NO;
        self.beacon4RoleLabel.hidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // For testing, loads from JSON. In reality we will load from the
    // onboarding process that Estimote provides us (see note below)
    
    if (!self.myLocation) {
        [self loadLocationsFromJSON];
        //[self showLocationSetup];
    }
    
    else {
        NSLog(@"We got my location: %@", self.myLocation);
        [self.db getBeacons];
    }

}

- (void)authorizeEnlight
{
    [ESTConfig setupAppID:TLEstimoteAppID andAppToken:TLEstimoteAppToken];
}

// [AK] =============================================================
// @TODO: Right now this loads directly from the json file which has all
// the relevant information to make a 'ESTLocation' (that's what they call
// the whole room + beacons + etc. After we get all the UI working, we can
// replace that JSON location with the Location object that Estimote gives us
// from this 'showLocationSetup' onboarding process (this is the thing where
// they guide the user around the room to set up the beacons
// [AK] =============================================================

- (void)showLocationSetup
{
    __weak EnlightEstimoteViewController *weakSelf = self;
    UIViewController *nextVC = [ESTIndoorLocationManager locationSetupControllerWithCompletion:^(ESTLocation *location, NSError *error) {
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (location) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Done" message:[NSString stringWithFormat:@"%@", location] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                NSLog(@"We got a location: %@", location);
                
                self.myLocation = location;
                
                [self putLocationDataToParse];
                
                [self mapBeaconsOnScreenWithLocation:(ESTLocation *)location];
            }
            
            else {
                NSLog(@"No location");
            }
        }];

    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:nextVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)putLocationDataToParse
{
    [self.myLocation.beacons enumerateObjectsUsingBlock:^(ESTPositionedBeacon *beacon, NSUInteger idx, BOOL *stop) {
        float beaconXPos = beacon.position.x;
        float beaconYPos = beacon.position.y;
        NSLog(@"beaconXPos in enlightestimoteviewcontroller: %.2f, beaconYPos = %.2f", beaconXPos, beaconYPos);
        [self.db setBeacon:nil withRole:nil withUDID:nil withMajor:nil withMinor:nil withX:beaconXPos withY:beaconYPos withMacAdd:beacon.macAddress];
    }];
}

// For testing
- (void)loadLocationsFromJSON
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ashwinLocation" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    ESTLocation *location = [ESTLocationBuilder parseFromJSON:content];
    self.myLocation = location;
    [self mapBeaconsOnScreenWithLocation:(ESTLocation *)location];
}

- (void)beaconsReturned:(NSMutableArray *)beacons
{
    NSLog(@"Beacons: %@", beacons);
}


// [AK] =============================================================
// Calculates where on the wall the beacon actually is, and also
// adjusts the color of the beacon image based on which beacon it is
// [AK] =============================================================

- (void)mapBeaconsOnScreenWithLocation:(ESTLocation *)location
{
    UIView *roomView = self.roomViewRectangle;
    [location.beacons enumerateObjectsUsingBlock:^(ESTPositionedBeacon *beacon, NSUInteger idx, BOOL *stop) {
        
        int relevantLineSegmentIdx = (idx > 0) ? idx-1 : 3;
        ESTOrientedLineSegment *relevantLineSegment = location.boundarySegments[relevantLineSegmentIdx];
        
        CGPoint linePoint1 = CGPointMake(relevantLineSegment.point1.x, relevantLineSegment.point1.y);
        CGPoint linePoint2 = CGPointMake(relevantLineSegment.point2.x, relevantLineSegment.point2.y);
        
        float lengthOfRelevantWall = [self lengthOfSegmentWithPoint1:linePoint1
                                                              point2:linePoint2];
        
        float lengthFromPoint1OfWallToBeacon = [self lengthOfSegmentWithPoint1:linePoint1
                                                                        point2:CGPointMake(beacon.position.x, beacon.position.y)];
        
        float beaconPercentFromPoint1OfWall = lengthFromPoint1OfWallToBeacon / lengthOfRelevantWall;
        
        NSString *beaconMacAddress = beacon.macAddress;
        NSArray *beaconArr = [[AppConstants beaconMapping] objectForKey:beaconMacAddress];
        UIImage *beaconBackgroundImage = [UIImage imageNamed:beaconArr[2]];
        NSString *currentBeaconColor = beaconArr[1];
        
        switch (idx) {
            case 0: {
                float bottomLeftX = roomView.frame.origin.x;
                float bottomRightX = roomView.frame.origin.x + roomView.frame.size.width;
                float beaconXPosition = bottomLeftX + ((bottomRightX - bottomLeftX)*beaconPercentFromPoint1OfWall);
                float beaconYPosition = roomView.frame.origin.y + roomView.frame.size.height;
                self.beacon1Button = [[UIButton alloc] initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2), beaconButtonImageWidth, beaconButtonImageHeight)];
                [self.beacon1Button setImage:beaconBackgroundImage forState:UIControlStateNormal];
                [self.beacon1Button addTarget:self action:@selector(choosingBeacon1Role) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:self.beacon1Button];
                
                self.beacon1Color = currentBeaconColor;
                break;
            }
                
            case 1: {
                float bottomRightY = roomView.frame.origin.y + roomView.frame.size.height;
                float topRightY = roomView.frame.origin.y;
                float beaconYPosition = bottomRightY - ((bottomRightY - topRightY) * beaconPercentFromPoint1OfWall);
                float beaconXPosition = roomView.frame.origin.x + roomView.frame.size.width;
                self.beacon2Button = [[UIButton alloc] initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2), beaconButtonImageWidth, beaconButtonImageHeight)];
                [self.beacon2Button setImage:beaconBackgroundImage forState:UIControlStateNormal];
                [self.beacon2Button addTarget:self action:@selector(choosingBeacon2Role) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:self.beacon2Button];
                
                self.beacon2Color = currentBeaconColor;
                break;
            }
                
            case 2: {
                float topLeftX = roomView.frame.origin.x;
                float topRightX = roomView.frame.origin.x + roomView.frame.size.width;
                float beaconXPosition = topRightX - ((topRightX - topLeftX) * beaconPercentFromPoint1OfWall);
                float beaconYPosition = roomView.frame.origin.y;
                self.beacon3Button = [[UIButton alloc] initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2), beaconButtonImageWidth, beaconButtonImageHeight)];
                [self.beacon3Button setImage:beaconBackgroundImage forState:UIControlStateNormal];
                [self.beacon3Button addTarget:self action:@selector(choosingBeacon3Role) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:self.beacon3Button];
                
                self.beacon3Color = currentBeaconColor;
                break;
            }

                
            case 3: {
                float topLeftY = roomView.frame.origin.y;
                float bottomLeftY = roomView.frame.origin.y + roomView.frame.size.height;
                float beaconYPosition = topLeftY + ((bottomLeftY-topLeftY)*beaconPercentFromPoint1OfWall);
                float beaconXPosition = roomView.frame.origin.x;
                self.beacon4Button = [[UIButton alloc] initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2), beaconButtonImageWidth, beaconButtonImageHeight)];
                [self.beacon4Button setImage:beaconBackgroundImage forState:UIControlStateNormal];
                [self.beacon4Button addTarget:self action:@selector(choosingBeacon4Role) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:self.beacon4Button];
                
                self.beacon4Color = currentBeaconColor;
                break;
            }

            default:
                break;
        }
    }];
}


#pragma mark - Action sheets

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
    else if (actionSheet.tag == 100)
    {
        self.beacon1RoleLabel.text = [AppConstants beaconRoleList][buttonIndex];
    }
    
    else if (actionSheet.tag == 200)
    {
        self.beacon2RoleLabel.text = [AppConstants beaconRoleList][buttonIndex];
    }
    
    else if (actionSheet.tag == 300) {
        self.beacon3RoleLabel.text = [AppConstants beaconRoleList][buttonIndex];
    }
    
    else if (actionSheet.tag == 400) {
        self.beacon4RoleLabel.text = [AppConstants beaconRoleList][buttonIndex];
    }
    
    [self checkIfRolesAreAllAssigned];
}

- (void)choosingBeacon1Role
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose the Beacon's Role" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Restroom", @"Cashier", @"Front Door", @"Exit", nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
}

- (void)choosingBeacon2Role
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose the Beacon's Role" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Restroom", @"Cashier", @"Front Door", @"Exit", nil];
    actionSheet.tag = 200;
    [actionSheet showInView:self.view];
}

- (void)choosingBeacon3Role
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose the Beacon's Role" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Restroom", @"Cashier", @"Front Door", @"Exit", nil];
    actionSheet.tag = 300;
    [actionSheet showInView:self.view];
}

- (void)choosingBeacon4Role
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose the Beacon's Role" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Restroom", @"Cashier", @"Front Door", @"Exit", nil];
    actionSheet.tag = 400;
    [actionSheet showInView:self.view];
}

// If all the beacons are assigned, user can press 'done' button and move on
- (void)checkIfRolesAreAllAssigned
{
    if (self.beacon1RoleLabel.text.length && self.beacon2RoleLabel.text.length && self.beacon3RoleLabel.text.length && self.beacon4RoleLabel.text.length) {
        self.doneButton.hidden = NO;
        self.pleaseSelectRolesLabel.hidden = YES;
    }
}

- (void)doneConfiguringBeacons
{
    NSDictionary *configuredBeacons = @{self.beacon1Color: self.beacon1RoleLabel.text,
                                        self.beacon2Color: self.beacon2RoleLabel.text,
                                        self.beacon3Color: self.beacon3RoleLabel.text,
                                        self.beacon4Color: self.beacon4RoleLabel.text};
    [self.db setAllBeaconsWithConfig:configuredBeacons];
    [self performSegueWithIdentifier:@"wandSegue" sender:self];
}


#pragma mark - Other

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"wandSegue"]) {
        WandViewController *wandViewController = (WandViewController *)segue.destinationViewController;
        wandViewController.myLocation = self.myLocation;
    }
}

- (float)lengthOfSegmentWithPoint1:(CGPoint)point1
                            point2:(CGPoint)point2
{
    CGFloat distance = hypotf(point1.x - point2.x, point1.y - point2.y);
    return distance;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
