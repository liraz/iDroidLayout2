//
//  IDLInsetDrawable.m
//  iDroidLayout2
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLInsetDrawable.h"
#import "IDLDrawable+IDL_Internal.h"
#import "IDLResourceManager.h"
#import "TBXML+IDL.h"

@interface IDLInsetDrawableConstantState ()

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, strong) IDLDrawable *drawable;

@end

@implementation IDLInsetDrawableConstantState

- (void)dealloc {
    self.drawable.delegate = nil;
}

- (instancetype)initWithState:(IDLInsetDrawableConstantState *)state owner:(IDLInsetDrawable *)owner {
    self = [super init];
    if (self) {
        if (state != nil) {
            self.insets = state.insets;
            IDLDrawable *copiedDrawable = [state.drawable copy];
            copiedDrawable.delegate = owner;
            self.drawable = copiedDrawable;
        }
    }
    return self;
}

@end

@interface IDLInsetDrawable ()

@property (nonatomic, strong) IDLInsetDrawableConstantState *internalConstantState;

@end

@implementation IDLInsetDrawable


- (instancetype)initWithState:(IDLInsetDrawableConstantState *)state {
    self = [super init];
    if (self) {
        IDLInsetDrawableConstantState *s = [[IDLInsetDrawableConstantState alloc] initWithState:state owner:self];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)drawInContext:(CGContextRef)context {
    [self.internalConstantState.drawable drawInContext:context];
    OUTLINE_RECT(context, self.bounds);
}

- (CGSize)minimumSize {
    return self.internalConstantState.drawable.minimumSize;
}

- (CGSize)intrinsicSize {
    return self.internalConstantState.drawable.intrinsicSize;
}

- (void)onStateChangeToState:(UIControlState)state {
    self.internalConstantState.drawable.state = self.state;
    [self onBoundsChangeToRect:self.bounds];
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    [super onBoundsChangeToRect:bounds];
    CGRect insetRect = UIEdgeInsetsInsetRect(self.bounds, self.internalConstantState.insets);
    self.internalConstantState.drawable.bounds = insetRect;
}

- (BOOL)onLevelChangeToLevel:(NSUInteger)level {
    return [self.internalConstantState.drawable setLevel:level];
}

- (UIEdgeInsets)padding {
    UIEdgeInsets insets = self.internalConstantState.insets;
    if (self.internalConstantState.drawable.hasPadding) {
        UIEdgeInsets childInsets = self.internalConstantState.drawable.padding;
        insets.left += childInsets.left;
        insets.top += childInsets.top;
        insets.right += childInsets.right;
        insets.bottom += childInsets.bottom;
    }
    return insets;
}

- (BOOL)hasPadding {
    return self.internalConstantState.drawable.hasPadding || !UIEdgeInsetsEqualToEdgeInsets(self.internalConstantState.insets, UIEdgeInsetsZero);
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *attrs = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.left = [attrs[@"insetLeft"] floatValue];
    insets.top = [attrs[@"insetTop"] floatValue];
    insets.right = [attrs[@"insetRight"] floatValue];
    insets.bottom = [attrs[@"insetBottom"] floatValue];
    
    NSString *drawableResId = attrs[@"drawable"];
    IDLDrawable *drawable = nil;
    if (drawableResId != nil) {
        drawable = [[IDLResourceManager currentResourceManager] drawableForIdentifier:drawableResId];
    } else if (element->firstChild != NULL) {
        drawable = [IDLDrawable createFromXMLElement:element->firstChild];
    } else {
        NSLog(@"<item> tag requires a 'drawable' attribute or child tag defining a drawable");
    }
    if (drawable != nil) {
        drawable.delegate = self;
        drawable.state = self.state;
        self.internalConstantState.drawable = drawable;
        self.internalConstantState.insets = insets;
    }
}

- (IDLDrawableConstantState *)constantState {
    return self.internalConstantState;
}

#pragma mark - IDLDrawableDelegate

- (void)drawableDidInvalidate:(IDLDrawable *)drawable {
    [self.delegate drawableDidInvalidate:self];
}

@end
