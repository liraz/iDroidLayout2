//
//  IDLClipDrawable.h
//  iDroidLayout2
//
//  Created by Tom Quist on 07.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "iDroidLayout2.h" // iDroidLayout2

typedef NS_ENUM(NSInteger, IDLClipDrawableOrientation) {
    IDLClipDrawableOrientationNone = 0,
    IDLClipDrawableOrientationHorizontal = 1,
    IDLClipDrawableOrientationVertical = 2
};

@interface IDLClipDrawable : IDLDrawable <IDLDrawableDelegate>

@end

@interface IDLClipDrawableConstantState : IDLDrawableConstantState

@end
