//
//  UILabel+IDL_View.h
//  iDroidLayout2
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDLGravity.h"
#import "IDLDrawable.h"

@interface UILabel (IDL_View) <IDLDrawableDelegate>

@property (nonatomic, assign) IDLViewContentGravity gravity;

@end
