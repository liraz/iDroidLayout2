//
//  IDLDrawableLayer.h
//  iDroidLayout2
//
//  Created by Tom Quist on 30.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IDLDrawable.h" // iDroidLayout2

@interface IDLDrawableLayer : CALayer <IDLDrawableDelegate>

@property (nonatomic, strong) IDLDrawable *drawable;

@end
