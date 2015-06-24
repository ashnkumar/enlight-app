//
//  EnLightButton.m
//  EnLight
//
//  Created by Catherine Jue on 6/20/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import "EnLightButton.h"
#import <QuartzCore/QuartzCore.h>

#define lightFont @"OpenSans-Light"


@implementation EnLightButton

-(id)init
{
    self = [super init];
    return self;

}

-(void)setUp:(CGRect)frame
{
    self.frame = frame;
    self.backgroundColor = [AppConstants enLightBlue];
    [self.titleLabel setFont:[UIFont fontWithName:lightFont size:18.0]];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    if (backgroundColor == [AppConstants enLightBlue])
    {
        [self setTitleColor:[AppConstants enLightWhite] forState:UIControlStateNormal];
    }
    else if (backgroundColor == [AppConstants enLightWhite])
    {
        [self setTitleColor:[AppConstants enLightBlue] forState:UIControlStateNormal];
    }
}

-(void)setBorder:(BOOL)yesOrNo
{
    if (yesOrNo == YES);
    {
        self.layer.borderWidth = 1;
        self.layer.borderColor = self.backgroundColor.CGColor;
    }
}

-(void)setFontSize:(float)size
{
    [self.titleLabel setFont:[UIFont fontWithName:lightFont size:size]];
}

@end
