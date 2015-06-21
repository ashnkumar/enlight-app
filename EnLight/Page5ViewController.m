//
//  Page5ViewController.m
//  EnLight
//
//  Created by Catherine Jue on 6/20/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "Page5ViewController.h"
#import "EnLightButton.h"

#define screenWidth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
#define halfOfScreenWidth [[UIScreen mainScreen] bounds].size.width/2
#define halfOfScreenHeight [[UIScreen mainScreen] bounds].size.height/2
#define lightFont @"OpenSans-Light"

@interface Page5ViewController ()

@end

@implementation Page5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //TODO: replace with a video of someone removing beacons from their box
    self.view.backgroundColor = [AppConstants enLightBlack];
    
    float descriptionLabelWidth = screenWidth * 0.75;
    float halfLabelWidth = descriptionLabelWidth/2;
    UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2-halfLabelWidth, halfOfScreenHeight-92, descriptionLabelWidth, 100)];
    descriptionLabel.text = @"Almost there — let's add a beacon near your cash register.";
    descriptionLabel.numberOfLines = 0;
    
    [descriptionLabel setFont:[UIFont fontWithName:lightFont size:20.0]];
    descriptionLabel.textColor = [AppConstants enLightWhite];
    [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:descriptionLabel];
    
    EnLightButton *nextButton = [[EnLightButton alloc]init];
    float nextButtonYcoord = descriptionLabel.frame.origin.y + 100 + 20;
    [nextButton setUp:CGRectMake(screenWidth/2-100, nextButtonYcoord, 200, 44)];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UILabel *subscriptLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, screenHeight-50, screenWidth-20, 50)];
    subscriptLabel.text = @"For testing purposes, place a beacon on a different wall to simulate a cash register.";
    subscriptLabel.numberOfLines = 0;
    [subscriptLabel setFont:[UIFont fontWithName:lightFont size:8.0]];
    subscriptLabel.textColor = [AppConstants enLightWhite];
    [subscriptLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:subscriptLabel];
    
    
}

- (void)nextButtonPressed
{
    [self performSegueWithIdentifier:@"toWand" sender:self];
}

@end
