//
//  UIView+IDL.h
//  iDroidLayout2
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDLLayoutParams.h"

/**
 * This is used by the layout-inflater to pass an action target to a UIControl
 */
FOUNDATION_EXPORT NSString *const IDLViewAttributeActionTarget;

typedef NS_ENUM(NSInteger, IDLLayoutMeasureSpecMode) {
    IDLLayoutMeasureSpecModeUnspecified,
    IDLLayoutMeasureSpecModeExactly,
    IDLLayoutMeasureSpecModeAtMost
};

typedef struct IDLLayoutMeasureSpec {
    CGFloat size;
    IDLLayoutMeasureSpecMode mode;
} IDLLayoutMeasureSpec;

IDLLayoutMeasureSpec IDLLayoutMeasureSpecMake(CGFloat size, IDLLayoutMeasureSpecMode mode);

typedef NS_OPTIONS(NSInteger, IDLLayoutMeasuredState) {
    IDLLayoutMeasuredStateNone = 0x0,
    IDLLayoutMeasuredStateTooSmall = 0x1
};

typedef struct IDLLayoutMeasuredDimension {
    CGFloat size;
    IDLLayoutMeasuredState state;
} IDLLayoutMeasuredDimension;

typedef struct IDLLayoutMeasuredSize {
    IDLLayoutMeasuredDimension width;
    IDLLayoutMeasuredDimension height;
} IDLLayoutMeasuredSize;

typedef struct IDLLayoutMeasuredWidthHeightState {
    IDLLayoutMeasuredState widthState;
    IDLLayoutMeasuredState heightState;
} IDLLayoutMeasuredWidthHeightState;

typedef NS_OPTIONS(NSInteger, IDLViewVisibility) {
    IDLViewVisibilityVisible = 0x00000000,
    IDLViewVisibilityInvisible = 0x00000004,
    IDLViewVisibilityGone = 0x00000008
};

IDLViewVisibility IDLViewVisibilityFromString(NSString *visibilityString);

IDLLayoutMeasuredSize IDLLayoutMeasuredSizeMake(IDLLayoutMeasuredDimension width, IDLLayoutMeasuredDimension height);

BOOL BOOLFromString(NSString *boolString);

@interface UIView (IDL_Layout)

@property (nonatomic, retain) IDLLayoutParams *layoutParams;
@property (nonatomic, assign) CGSize minSize;
@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, readonly) CGSize measuredSize;
@property (nonatomic, readonly) IDLLayoutMeasuredWidthHeightState measuredState;
@property (nonatomic, readonly) CGFloat baseline;
@property (nonatomic, readonly) BOOL isLayoutRequested;
@property (nonatomic, assign) NSString *identifier;
@property (nonatomic, assign) IDLViewVisibility visibility;

- (instancetype)initWithAttributes:(NSDictionary *)attrs;
- (void)setupFromAttributes:(NSDictionary *)attrs;
- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec;
- (void)measureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec;

- (void)layoutWithFrame:(CGRect)frame;


- (void)onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed;
- (void)onRemovedFromSuperview;
- (void)onAddedToSuperview;

- (void)setMeasuredDimensionSize:(IDLLayoutMeasuredSize)size;
- (void)requestLayout;
- (void)measureAndLayout;
- (void)onFinishInflate;
- (UIView *)findViewById:(NSString *)identifier;

+ (IDLLayoutMeasuredWidthHeightState)combineMeasuredStatesCurrentState:(IDLLayoutMeasuredWidthHeightState)curState newState:(IDLLayoutMeasuredWidthHeightState)newState;
+ (IDLLayoutMeasuredDimension)resolveSizeAndStateForSize:(CGFloat)size measureSpec:(IDLLayoutMeasureSpec)measureSpec childMeasureState:(IDLLayoutMeasuredState)childMeasuredState;
+ (CGFloat)resolveSizeForSize:(CGFloat)size measureSpec:(IDLLayoutMeasureSpec)measureSpec;

@end
