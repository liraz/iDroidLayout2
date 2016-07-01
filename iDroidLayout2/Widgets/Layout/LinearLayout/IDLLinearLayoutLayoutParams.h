//
//  LinearLayoutLayoutParams.h
//  iDroidLayout2
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLMarginLayoutParams.h"
#import "IDLViewGroup.h"
#import "IDLGravity.h"

@interface IDLLinearLayoutLayoutParams : IDLMarginLayoutParams

@property (nonatomic, assign) IDLViewContentGravity gravity;
@property (nonatomic, assign) float weight;

@end
