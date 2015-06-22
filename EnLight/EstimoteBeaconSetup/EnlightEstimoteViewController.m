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
@property (weak, nonatomic) IBOutlet UILabel *beacon1RoleLabel;
@property (weak, nonatomic) IBOutlet UILabel *beacon2RoleLabel;
@property (weak, nonatomic) IBOutlet UILabel *beacon3RoleLabel;
@property (weak, nonatomic) IBOutlet UILabel *beacon4RoleLabel;

// other
@property (strong, nonatomic) EnLightDBManager *db;
@property (weak, nonatomic) IBOutlet UIView *roomViewRectangle;
@property (strong, nonatomic) ESTLocation *myLocation;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *pleaseSelectRolesLabel;

@end

@implementation EnlightEstimoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.db = [[EnLightDBManager alloc]init];
    self.db.delegate = self;
    
    self.doneButton.hidden = NO;
    self.pleaseSelectRolesLabel.hidden = NO;
    
    [self authorizeEnlight];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // For testing
    if (!self.myLocation) {
        [self loadLocationsFromJSON];
        //    [self showLocationSetup];
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

- (void)showLocationSetup
{
    __weak EnlightEstimoteViewController *weakSelf = self;
    UIViewController *nextVC = [ESTIndoorLocationManager locationSetupControllerWithCompletion:^(ESTLocation *location, NSError *error) {
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (location) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Done" message:[NSString stringWithFormat:@"%@", location] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                NSLog(@"We got a location: %@", location);
//                self.myLocation = location;
//                [self mapBeaconsOnScreenWithLocation:(ESTLocation *)location];
            }
            
            else {
                NSLog(@"No location");
            }
        }];

    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:nextVC];
    [self presentViewController:navController animated:YES completion:nil];
    
    
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

- (void)mapBeaconsOnScreenWithLocation:(ESTLocation *)location
{
    UIView *roomView = self.roomViewRectangle;
//    NSLog(@"Boudnary segments: %@", location.boundarySegments);
    [location.beacons enumerateObjectsUsingBlock:^(ESTPositionedBeacon *beacon, NSUInteger idx, BOOL *stop) {
        
        int relevantLineSegmentIdx = (idx > 0) ? idx-1 : 3;
        ESTOrientedLineSegment *relevantLineSegment = location.boundarySegments[relevantLineSegmentIdx];
//        NSLog(@"Line segment: %@", relevantLineSegment);
//        NSLog(@"Line segment length: %.2f", relevantLineSegment.length);
        
        CGPoint linePoint1 = CGPointMake(relevantLineSegment.point1.x, relevantLineSegment.point1.y);
        CGPoint linePoint2 = CGPointMake(relevantLineSegment.point2.x, relevantLineSegment.point2.y);
        
        float lengthOfRelevantWall = [self lengthOfSegmentWithPoint1:linePoint1
                                                              point2:linePoint2];
        
        float lengthFromPoint1OfWallToBeacon = [self lengthOfSegmentWithPoint1:linePoint1
                                                                        point2:CGPointMake(beacon.position.x, beacon.position.y)];
        
        float beaconPercentFromPoint1OfWall = lengthFromPoint1OfWallToBeacon / lengthOfRelevantWall;
//        NSLog(@"percent: %.4f", beaconPercentFromPoint1OfWall);
        
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
    if (actionSheet.tag == 100)
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Beacon Role" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Restroom", @"Cashier", @"Front Door", @"Exit", nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
}

- (void)choosingBeacon2Role
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Beacon Role" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Restroom", @"Cashier", @"Front Door", @"Exit", nil];
    actionSheet.tag = 200;
    [actionSheet showInView:self.view];
}

- (void)choosingBeacon3Role
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Beacon Role" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Restroom", @"Cashier", @"Front Door", @"Exit", nil];
    actionSheet.tag = 300;
    [actionSheet showInView:self.view];
}

- (void)choosingBeacon4Role
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Beacon Role" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Restroom", @"Cashier", @"Front Door", @"Exit", nil];
    actionSheet.tag = 400;
    [actionSheet showInView:self.view];
}

- (void)checkIfRolesAreAllAssigned
{
    if (self.beacon1RoleLabel.text.length && self.beacon2RoleLabel.text.length && self.beacon3RoleLabel.text.length && self.beacon4RoleLabel.text.length) {
        self.doneButton.hidden = NO;
        self.pleaseSelectRolesLabel.hidden = YES;
    }
}

- (IBAction)doneConfiguringBeacons:(id)sender
{
    NSDictionary *configuredBeacons = @{self.beacon1Color: self.beacon1RoleLabel.text,
                                        self.beacon2Color: self.beacon2RoleLabel.text,
                                        self.beacon3Color: self.beacon3RoleLabel.text,
                                        self.beacon4Color: self.beacon4RoleLabel.text};
    [self.db setAllBeaconsWithConfig:configuredBeacons];
    [self performSegueWithIdentifier:@"wandSegue" sender:self];
}


- (float)lengthOfSegmentWithPoint1:(CGPoint)point1
                            point2:(CGPoint)point2
{
    CGFloat distance = hypotf(point1.x - point2.x, point1.y - point2.y);

    return distance;
}

#pragma mark - Other

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"wandSegue"]) {
        WandViewController *wandViewController = (WandViewController *)segue.destinationViewController;
        wandViewController.myLocation = self.myLocation;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

@end
