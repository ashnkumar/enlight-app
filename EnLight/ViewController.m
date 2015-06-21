//
//  ViewController.m
//  EnLight
//
//  Created by Catherine Jue on 6/20/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "ViewController.h"
#import "EnLightButton.h"

#define screenWidth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
#define halfOfScreenWidth [[UIScreen mainScreen] bounds].size.width/2
#define halfOfScreenHeight [[UIScreen mainScreen] bounds].size.height/2
#define lightFont @"OpenSans-Light"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set up interface
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 60, screenWidth, 3)];
    line.backgroundColor = [AppConstants enLightBlue];
    [self.view addSubview:line];
    
    
    UILabel *welcomeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, halfOfScreenHeight-77, screenWidth, 30)];
    welcomeLabel.text = @"Welcome!";
    [welcomeLabel setFont:[UIFont fontWithName:lightFont size:30.0]];
    [welcomeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:welcomeLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, welcomeLabel.frame.origin.y+30, screenWidth, 60)];
    descriptionLabel.text = @"Let's set up your\nEnLight beacons.";
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel setFont:[UIFont fontWithName:lightFont size:20.0]];
    [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:descriptionLabel];
    
    EnLightButton *nextButton = [[EnLightButton alloc]init];
    float nextButtonYcoord = descriptionLabel.frame.origin.y + 40 + 40;
    [nextButton setUp:CGRectMake(screenWidth/2-100, nextButtonYcoord, 200, 44)];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UILabel *subscriptLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, screenHeight-50, screenWidth-20, 50)];
    subscriptLabel.text = @"For testing purposes of this hackathon, we have combined the merchant’s beacon configuration app and consumer app into one.  This sample app works best in a single room, as additional beacons are required to accommodate an entire building.";
    subscriptLabel.numberOfLines = 0;
    [subscriptLabel setFont:[UIFont fontWithName:lightFont size:14.0]];
    [subscriptLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:subscriptLabel];
    
}

- (void)nextButtonPressed
{
    [self performSegueWithIdentifier:@"toPage2" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
