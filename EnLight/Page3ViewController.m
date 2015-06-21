//
//  Page3ViewController.m
//  EnLight
//
//  Created by Catherine Jue on 6/20/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "Page3ViewController.h"
#import "EnLightButton.h"

#define screenWidth [[UIScreen mainScreen] bounds].size.width
#define screenHeight [[UIScreen mainScreen] bounds].size.height
#define halfOfScreenWidth [[UIScreen mainScreen] bounds].size.width/2
#define halfOfScreenHeight [[UIScreen mainScreen] bounds].size.height/2
#define lightFont @"OpenSans-Light"

@interface Page3ViewController ()

@end

@implementation Page3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //TODO: replace with a video of someone removing beacons from their box
    self.view.backgroundColor = [AppConstants enLightBlack];
    
    float descriptionLabelWidth = screenWidth * 0.75;
    float halfLabelWidth = descriptionLabelWidth/2;
    UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2-halfLabelWidth, halfOfScreenHeight-102, descriptionLabelWidth, 120)];
    descriptionLabel.text = @"Let's set a beacon at your front door, so visually impaired visitors can easily locate it.";
    descriptionLabel.numberOfLines = 0;
    
    [descriptionLabel setFont:[UIFont fontWithName:lightFont size:20.0]];
    descriptionLabel.textColor = [AppConstants enLightWhite];
    [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:descriptionLabel];
    
    UILabel *subscriptLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, screenHeight-50, screenWidth-20, 50)];
    subscriptLabel.text = @"For testing purposes, please simulate our merchant's configuration by placing the beacon next to a door.";
    subscriptLabel.numberOfLines = 0;
    [subscriptLabel setFont:[UIFont fontWithName:lightFont size:8.0]];
    subscriptLabel.textColor = [AppConstants enLightWhite];
    [subscriptLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:subscriptLabel];
    
    EnLightButton *nextButton = [[EnLightButton alloc]init];
    float nextButtonYcoord = descriptionLabel.frame.origin.y + 100 + 40;
    [nextButton setUp:CGRectMake(screenWidth/2-100, nextButtonYcoord, 200, 44)];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
}

- (void)nextButtonPressed
{
    [self performSegueWithIdentifier:@"toPage4" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
