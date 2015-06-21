//
//  EnLightButton.h
//  EnLight
//
//  Created by Catherine Jue on 6/20/15.
//  Copyright (c) 2015 Catherine Jue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"

@interface EnLightButton : UIButton
-(void)setUp:(CGRect)frame;
-(void)setBackgroundColor:(UIColor *)backgroundColor;
-(void)setBorder:(BOOL)yesOrNo;
-(void)setFontSize:(float)size;

@end
