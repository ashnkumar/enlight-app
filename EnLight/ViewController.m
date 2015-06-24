//
//  ViewController.m
//  EnLight
//
//  Created by Catherine Jue on 6/20/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "ViewController.h"
#import "EnLightButton.h"
#import <AVFoundation/AVFoundation.h>

#define screenWidth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
#define halfOfScreenWidth [[UIScreen mainScreen] bounds].size.width/2
#define halfOfScreenHeight [[UIScreen mainScreen] bounds].size.height/2
#define lightFont @"OpenSans-Light"

#define estimoteSetupSegue @"estimoteSetupSegue"

@interface ViewController ()
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set up interface
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(halfOfScreenWidth-22, 40, 44, 44)];
    [logo setImage:[UIImage imageNamed:@"EnLightLogoReversed"]];
    [self.view addSubview:logo];
    
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
    
    UILabel *subscriptLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, screenHeight-80-10, screenWidth-20, 80)];
    subscriptLabel.text = @"For testing purposes, we've combined the merchant’s beacon configuration wand and consumer app into one.  This test version works best in a single room.";
    subscriptLabel.numberOfLines = 0;
    [subscriptLabel setFont:[UIFont fontWithName:lightFont size:14.0]];
    [subscriptLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:subscriptLabel];
    
    self.synthesizer = [[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Welcome! Let's set up your beacons. For testing purposes, we've combined the merchant’s beacon configuration app and consumer wand into one.  This test version works best in a single room as more beacons are needed for an entire building."];
    
    utterance.pitchMultiplier = 1.0;
    utterance.rate = 0.1;
    
    [self.synthesizer speakUtterance:utterance];
}

- (void)nextButtonPressed
{
    [self performSegueWithIdentifier:estimoteSetupSegue sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

@end
