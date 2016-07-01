//
//  IDLButton.h
//  iDroidLayout2
//
//  Created by Tom Quist on 05.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDLLinearLayout.h"

@interface IDLButton : IDLLinearLayout

@property (retain, nonatomic) UIImageView* drawableLeftImage;
@property (retain, nonatomic) UIImageView* drawableRightImage;
@property (retain, nonatomic) UIView* passTouchesToView;

@end
