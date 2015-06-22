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

#define TLEstimoteAppID @"enlight"
#define TLEstimoteAppToken @"0bc9e8569d2de758ce7700942af03190"
const float beaconButtonImageWidth = 30.0;
const float beaconButtonImageHeight = 38.0;

@interface EnlightEstimoteViewController ()
@property (nonatomic, strong) UIButton *beacon1Button;
@property (nonatomic, strong) UIButton *beacon2Button;
@property (nonatomic, strong) UIButton *beacon3Button;
@property (nonatomic, strong) UIButton *beacon4Button;
@property (weak, nonatomic) IBOutlet UIView *roomViewRectangle;

@end

@implementation EnlightEstimoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self authorizeEnlight];
    
//    [self showLocationSetup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // For testing
    [self loadLocationsFromJSON];
//    [self showLocationSetup];
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
    
    [self mapBeaconsOnScreenWithLocation:(ESTLocation *)location];
    
}

- (void)mapBeaconsOnScreenWithLocation:(ESTLocation *)location
{
    UIView *roomView = self.roomViewRectangle;
//    NSLog(@"Boudnary segments: %@", location.boundarySegments);
    [location.beacons enumerateObjectsUsingBlock:^(ESTPositionedBeacon *beacon, NSUInteger idx, BOOL *stop) {
        
        int relevantLineSegmentIdx = (idx > 0) ? idx-1 : 3;
        ESTOrientedLineSegment *relevantLineSegment = location.boundarySegments[relevantLineSegmentIdx];
//        NSLog(@"Line segment: %@", relevantLineSegment);
        
        CGPoint linePoint1 = CGPointMake(relevantLineSegment.point1.x, relevantLineSegment.point1.y);
        CGPoint linePoint2 = CGPointMake(relevantLineSegment.point2.x, relevantLineSegment.point2.y);
        
        float lengthOfRelevantWall = [self lengthOfSegmentWithPoint1:linePoint1
                                                              point2:linePoint2];
        
        float lengthFromPoint1OfWallToBeacon = [self lengthOfSegmentWithPoint1:linePoint1
                                                                        point2:CGPointMake(beacon.position.x, beacon.position.y)];
        
        float beaconPercentFromPoint1OfWall = lengthFromPoint1OfWallToBeacon / lengthOfRelevantWall;
        NSLog(@"percent: %.4f", beaconPercentFromPoint1OfWall);
        
        switch (idx) {
            case 0: {
                float bottomLeftX = roomView.frame.origin.x;
                float bottomRightX = roomView.frame.origin.x + roomView.frame.size.width;
                float beaconXPosition = bottomLeftX + ((bottomRightX - bottomLeftX)*beaconPercentFromPoint1OfWall);
                float beaconYPosition = roomView.frame.origin.y + roomView.frame.size.height;
                UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2), beaconButtonImageWidth, beaconButtonImageHeight)];
                newView.backgroundColor = [UIColor greenColor];
                [self.view addSubview:newView];
                break;
            }
                
            case 1: {
                float bottomRightY = roomView.frame.origin.y + roomView.frame.size.height;
                float topRightY = roomView.frame.origin.y;
                float beaconYPosition = bottomRightY - ((bottomRightY - topRightY) * beaconPercentFromPoint1OfWall);
                float beaconXPosition = roomView.frame.origin.x + roomView.frame.size.width;
                UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2), beaconButtonImageWidth, beaconButtonImageHeight)];
                newView.backgroundColor = [UIColor blueColor];
                [self.view addSubview:newView];
                break;
            }
                
            case 2: {
                float topLeftX = roomView.frame.origin.x;
                float topRightX = roomView.frame.origin.x + roomView.frame.size.width;
                float beaconXPosition = topRightX - ((topRightX - topLeftX) * beaconPercentFromPoint1OfWall);
                float beaconYPosition = roomView.frame.origin.y;
                UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2), beaconButtonImageWidth, beaconButtonImageHeight)];
                newView.backgroundColor = [UIColor grayColor];
                [self.view addSubview:newView];
                break;
            }

                
            case 3: {
                float topLeftY = roomView.frame.origin.y;
                float bottomLeftY = roomView.frame.origin.y + roomView.frame.size.height;
                float beaconYPosition = topLeftY + ((bottomLeftY-topLeftY)*beaconPercentFromPoint1OfWall);
                float beaconXPosition = roomView.frame.origin.x;
                UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(beaconXPosition-(beaconButtonImageWidth/2), beaconYPosition-(beaconButtonImageHeight/2), beaconButtonImageWidth, beaconButtonImageHeight)];
                newView.backgroundColor = [UIColor purpleColor];
                [self.view addSubview:newView];
                break;
            }

            default:
                break;
        }
        
    }];
}

// 30, 38


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
