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

#define TLEstimoteAppID @"enlight"
#define TLEstimoteAppToken @"0bc9e8569d2de758ce7700942af03190"

@interface EnlightEstimoteViewController ()

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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
