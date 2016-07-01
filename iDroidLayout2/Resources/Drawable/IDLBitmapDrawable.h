//
//  IDLBitmapDrawable.h
//  iDroidLayout2
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"
#import "IDLGravity.h"

@interface IDLBitmapDrawable : IDLDrawable

- (instancetype)initWithImage:(UIImage *)image NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, strong) UIImage * image;

@end

@interface IDLBitmapDrawableConstantState : IDLDrawableConstantState

@end
