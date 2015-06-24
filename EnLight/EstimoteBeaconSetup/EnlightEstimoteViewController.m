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
#import <QuartzCore/QuartzCore.h>

#define screenWidth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
#define halfOfScreenWidth [[UIScreen mainScreen] bounds].size.width/2
#define halfOfScreenHeight [[UIScreen mainScreen] bounds].size.height/2
#define lightFont @"OpenSans-Light"

//#define TLEstimoteAppID @"enlight"
//#define TLEstimoteAppToken @"0bc9e8569d2de758ce7700942af03190"
#define TLEstimoteAppID @"enlight-cat"
#define TLEstimoteAppToken @"094bf8bf4a7cc6fbb94939f8c16e76bc"

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
@property (strong, nonatomic) UIView *toolTip1;
@property (strong, nonatomic) UIView *toolTip2;
@property (strong, nonatomic) UIView *toolTip3;
@property (strong, nonatomic) UIView *toolTip4;
@property (strong, nonatomic) UILabel *toolTipLabel1;
@property (strong, nonatomic) UILabel *toolTipLabel2;
@property (strong, nonatomic) UILabel *toolTipLabel3;
@property (strong, nonatomic) UILabel *toolTipLabel4;

// other
@property (strong, nonatomic) EnLightDBManager *db;
@property (weak, nonatomic) IBOutlet UIView *roomViewRectangle;
@property (strong, nonatomic) ESTLocation *myLocation;
@property (strong, nonatomic) EnLightButton *doneButton;
@property (strong, nonatomic) UILabel *pleaseSelectRolesLabel;

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@end

@implementation EnlightEstimoteViewController
{
    BOOL drawnToolTip1Before;
    BOOL drawnToolTip2Before;
    BOOL drawnToolTip3Before;
    BOOL drawnToolTip4Before;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.db = [[EnLightDBManager alloc]init];
    self.synthesizer = [[AVSpeechSynthesizer alloc]init];
    self.db.delegate = self;
    self.roomViewRectangle.alpha = 0.0;
    
    //Tooltips setup
    drawnToolTip1Before = drawnToolTip2Before = drawnToolTip3Before = drawnToolTip4Before = NO;
    
    [self authorizeEnlight];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(waitToDecide) userInfo:nil repeats:NO];
}

- (void)authorizeEnlight
{
    [ESTConfig setupAppID:TLEstimoteAppID andAppToken:TLEstimoteAppToken];
    NSLog([ESTConfig isAuthorized] ? @"YES authorized" : @"NO not authorized");
}

- (void)waitToDecide
{
    if (!self.myLocation)
    {
        [self showLocationSetup];
    }
}

- (void)showLocationSetup
{
    __weak EnlightEstimoteViewController *weakSelf = self;
    UIViewController *nextVC = [ESTIndoorLocationManager locationSetupControllerWithCompletion:^(ESTLocation *location, NSError *error) {
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (location) {
                self.myLocation = location;
                
                //Accessibility
                AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Almost there! Let’s assign roles to each of the beacons. Tap each beacon and select its role from the menu provided."];
                
                utterance.pitchMultiplier = 1.0;
                utterance.rate = 0.1;
                
                [self.synthesizer speakUtterance:utterance];
                
                [self putLocationDataToParse]; //shouldwork
                
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
        [self.db setBeacon:nil withRole:nil withUDID:nil withMajor:nil withMinor:nil withX:beaconXPos withY:beaconYPos withMacAdd:beacon.macAddress];
    }];
}

// For testing
/*- (void)loadLocationsFromJSON
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ashwinLocation" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    ESTLocation *location = [ESTLocationBuilder parseFromJSON:content];
    self.myLocation = location;
    [self mapBeaconsOnScreenWithLocation:(ESTLocation *)location];
}*/

- (void)beaconsReturned:(NSMutableArray *)beacons
{
}

-(void)updateToolTip:(NSString *)role withToolTip:(int)num
{
    switch (num) {
        case 1:
        {
            self.toolTipLabel1.text = role;
            break;
        }
        case 2:
        {
            self.toolTipLabel2.text = role;
            break;
        }
        case 3:
        {
            self.toolTipLabel3.text = role;
            break;
        }
        case 4:
        {
            self.toolTipLabel4.text = role;
            break;
        }
        default:
            break;
    }
}

- (void)drawToolTip:(NSString *)role withToolTip:(int)num
{
    UIView *toolTipRect = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 25)];
    toolTipRect.backgroundColor = [AppConstants enLightBlue];
    toolTipRect.layer.cornerRadius = 4;
    toolTipRect.layer.masksToBounds = YES;
    
    UIImageView *triangleForToolTip = [[UIImageView alloc]initWithFrame:CGRectMake(5, 17, 17, 17)];
    [triangleForToolTip setImage:[UIImage imageNamed:@"toolTipTriangle"]];
    
    
    switch (num) {
        case 1:
        {
            [self.toolTip1 addSubview:toolTipRect];
            [self.toolTip1 addSubview:triangleForToolTip];
            
            self.toolTipLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(5, 1, 80-6, 25-4)];
            self.toolTipLabel1.text = role;
            [self.toolTipLabel1 setTextColor:[AppConstants enLightWhite]];
            [self.toolTipLabel1 setFont:[UIFont fontWithName:lightFont size:12.0]];
            [self.toolTipLabel1 setTextAlignment:NSTextAlignmentCenter];
            
            [self.toolTip1 addSubview:self.toolTipLabel1];
            [self.toolTip1 setHidden:NO];
            drawnToolTip1Before = YES;

            break;
        }
        case 2:
        {
            [self.toolTip2 addSubview:toolTipRect];
            [self.toolTip2 addSubview:triangleForToolTip];
            
            self.toolTipLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(5, 1, 80-6, 25-4)];
            self.toolTipLabel2.text = role;
            [self.toolTipLabel2 setTextColor:[AppConstants enLightWhite]];
            [self.toolTipLabel2 setFont:[UIFont fontWithName:lightFont size:12.0]];
            [self.toolTipLabel2 setTextAlignment:NSTextAlignmentCenter];
            
            [self.toolTip2 addSubview:self.toolTipLabel2];
            [self.toolTip2 setHidden:NO];
            drawnToolTip2Before = YES;

            break;
        }
        case 3:
        {
            [self.toolTip3 addSubview:toolTipRect];
            [self.toolTip3 addSubview:triangleForToolTip];

            self.toolTipLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(5, 1, 80-6, 25-4)];
            self.toolTipLabel3.text = role;
            [self.toolTipLabel3 setTextColor:[AppConstants enLightWhite]];
            [self.toolTipLabel3 setFont:[UIFont fontWithName:lightFont size:12.0]];
            [self.toolTipLabel3 setTextAlignment:NSTextAlignmentCenter];
            
            [self.toolTip3 addSubview:self.toolTipLabel3];
            [self.toolTip3 setHidden:NO];
            drawnToolTip3Before = YES;

            break;
        }
        case 4:
        {
            [self.toolTip4 addSubview:toolTipRect];
            [self.toolTip4 addSubview:triangleForToolTip];

            self.toolTipLabel4 = [[UILabel alloc]initWithFrame:CGRectMake(5, 1, 80-6, 25-4)];
            self.toolTipLabel4.text = role;
            [self.toolTipLabel4 setTextColor:[AppConstants enLightWhite]];
            [self.toolTipLabel4 setFont:[UIFont fontWithName:lightFont size:12.0]];
            [self.toolTipLabel4 setTextAlignment:NSTextAlignmentCenter];
            
            [self.toolTip4 addSubview:self.toolTipLabel4];
            [self.toolTip4 setHidden:NO];
            drawnToolTip4Before = YES;

            break;
        }
        default:
            break;
    }
    
}

- (void)setUpMerchantConfigView
{
    //Set up view
    self.roomViewRectangle.alpha = 1.0;
    
    //White rectangle at bottom of the screen
    UIView *whiteTextRect = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight - 110, screenWidth, 110)];
    whiteTextRect.backgroundColor = [AppConstants enLightWhite];
    [self.view addSubview:whiteTextRect];
    
    //Instructions inside white rectangle
    int selectRolesLabelWidth = screenWidth * .85;
    int selectRolesLabelHeight = 80;
    self.pleaseSelectRolesLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 - selectRolesLabelWidth/2, whiteTextRect.frame.size.height/2 - selectRolesLabelHeight/2, selectRolesLabelWidth, selectRolesLabelHeight)];
    self.pleaseSelectRolesLabel.text = @"Almost there! Let’s assign roles to each of the beacons. Tap each beacon and select its role from the menu provided.";
    self.pleaseSelectRolesLabel.hidden = NO;
    self.pleaseSelectRolesLabel.numberOfLines = 0;
    [self.pleaseSelectRolesLabel setTextColor:[AppConstants enLightBlack]];
    [self.pleaseSelectRolesLabel setFont:[UIFont fontWithName:lightFont size:15.0]];
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

    self.doneButton.hidden = YES;
    self.pleaseSelectRolesLabel.hidden = NO;
}

- (void)mapBeaconsOnScreenWithLocation:(ESTLocation *)location
{
    //Set up basic view
    [self setUpMerchantConfigView];

    //Set up beacon view
    UIView *roomView = self.roomViewRectangle;
    [location.beacons enumerateObjectsUsingBlock:^(ESTPositionedBeacon *beacon, NSUInteger idx, BOOL *stop) {
        
        //Draw the beacons
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
                
                //CAT set the tooltip
                self.toolTip1 = [[UIView alloc]initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2) - 5-30, 80, 35)];
                [self.view addSubview:self.toolTip1];
                [self.toolTip1 setHidden:YES];
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
                
                self.toolTip2 = [[UIView alloc]initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2) - 5-30, 80, 35)];
                [self.view addSubview:self.toolTip2];
                [self.toolTip2 setHidden:YES];
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
                
                self.toolTip3 = [[UIView alloc]initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2) - 5-30, 80, 35)];
                [self.view addSubview:self.toolTip3];
                [self.toolTip3 setHidden:YES];
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
                
                self.toolTip4 = [[UIView alloc]initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2) - 5-30, 80, 35)];
                [self.view addSubview:self.toolTip4];
                [self.toolTip4 setHidden:YES];
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
    int whichToolTip = 0;
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
    else if (actionSheet.tag == 100)
    {
        whichToolTip = 1;
        
        if (!drawnToolTip1Before)
            [self drawToolTip:[AppConstants beaconRoleList][buttonIndex] withToolTip:whichToolTip];
        else
        {
            [self updateToolTip:[AppConstants beaconRoleList][buttonIndex] withToolTip:whichToolTip];
        }
    }
    
    else if (actionSheet.tag == 200)
    {
        whichToolTip = 2;
        
        if (!drawnToolTip2Before)
            [self drawToolTip:[AppConstants beaconRoleList][buttonIndex] withToolTip:whichToolTip];
        else
        {
            [self updateToolTip:[AppConstants beaconRoleList][buttonIndex] withToolTip:whichToolTip];
        }
    }
    
    else if (actionSheet.tag == 300)
    {
        whichToolTip = 3;
        
        if (!drawnToolTip3Before)
            [self drawToolTip:[AppConstants beaconRoleList][buttonIndex] withToolTip:whichToolTip];
        else
        {
            [self updateToolTip:[AppConstants beaconRoleList][buttonIndex] withToolTip:whichToolTip];
        }
    }
    
    else if (actionSheet.tag == 400)
    {
        whichToolTip = 4;
        
        if (!drawnToolTip4Before)
            [self drawToolTip:[AppConstants beaconRoleList][buttonIndex] withToolTip:whichToolTip];
        else
        {
            [self updateToolTip:[AppConstants beaconRoleList][buttonIndex] withToolTip:whichToolTip];
        }
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
    if (self.toolTipLabel1.text.length && self.toolTipLabel2.text.length && self.toolTipLabel3.text.length && self.toolTipLabel4.text.length) {
        self.doneButton.hidden = NO;
        self.pleaseSelectRolesLabel.hidden = YES;
    }
}

- (void)doneConfiguringBeacons
{
    UIAlertView *finished = [[UIAlertView alloc]initWithTitle:@"Finished Configurations" message:@"Thank you for setting up your beacons!" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    [finished show];
    [self performSelector:@selector(hideAlert:) withObject:finished afterDelay:3];
}

- (void)hideAlert:(UIAlertView *)finished
{
    self.doneButton.hidden = YES;
    self.pleaseSelectRolesLabel.text = @"Here are your configured beacons.";
    self.pleaseSelectRolesLabel.hidden = NO;
    [finished dismissWithClickedButtonIndex:0 animated:YES];
    NSDictionary *configuredBeacons = @{self.beacon1Color: self.toolTipLabel1.text,
                                        self.beacon2Color: self.toolTipLabel2.text,
                                        self.beacon3Color: self.toolTipLabel3.text,
                                        self.beacon4Color: self.toolTipLabel4.text};
                                        [self.db setAllBeaconsRoles:configuredBeacons]; //put roles to db

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
