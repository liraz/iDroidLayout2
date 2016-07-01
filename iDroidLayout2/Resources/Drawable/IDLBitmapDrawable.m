//
//  IDLBitmapDrawable.m
//  iDroidLayout2
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLBitmapDrawable.h"
#import "IDLDrawable+IDL_Internal.h"
#import "TBXML+IDL.h"
#import "IDLResourceManager.h"
#import "UIImage+IDLNinePatch.h"

@interface IDLBitmapDrawableConstantState ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) IDLViewContentGravity gravity;

- (instancetype)initWithState:(IDLBitmapDrawableConstantState *)state;

@end

@implementation IDLBitmapDrawableConstantState


- (instancetype)initWithState:(IDLBitmapDrawableConstantState *)state {
    self = [super init];
    if (self) {
        if (state != nil) {
            self.image = state.image;
            self.gravity = state.gravity;
        } else {
            self.gravity = IDLViewContentGravityFill;
        }
    }
    return self;
}


@end

@interface IDLBitmapDrawable ()

@property (nonatomic, strong) IDLBitmapDrawableConstantState *internalConstantState;
@property (nonatomic, strong) UIImage *scaledImageCache;

- (instancetype)initWithState:(IDLBitmapDrawableConstantState *)state NS_DESIGNATED_INITIALIZER;

@end

@implementation IDLBitmapDrawable

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        IDLBitmapDrawableConstantState *state = [[IDLBitmapDrawableConstantState alloc] initWithState:nil];
        state.image = image;
        self.internalConstantState = state;
    }
    return self;
}

- (instancetype)initWithState:(IDLBitmapDrawableConstantState *)state {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        IDLBitmapDrawableConstantState *s = [[IDLBitmapDrawableConstantState alloc] initWithState:state];
        self.internalConstantState = s;
    }
    return self;
}

- (instancetype)init {
    return [self initWithState:nil];
}

- (void)didReceiveMemoryWarning {
    self.scaledImageCache = nil;
}

- (UIImage *)image {
    return self.internalConstantState.image;
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(CGFloat)width height:(CGFloat)height {
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the context because UIKit coordinate system is upside down to Quartz coordinate system
    CGContextTranslateCTM(context, 0.0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Draw the original image to the context
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    // Retrieve the UIImage from the current context
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

- (void)drawInContext:(CGContextRef)context withRect: (CGRect) rect {
    IDLBitmapDrawableConstantState *state = self.internalConstantState;
    CGRect containerRect = self.bounds;
    CGRect dstRect = rect;
    UIImage *image = state.image;
    int x = rect.origin.x;
    int y = rect.origin.y;

    [IDLGravity applyGravity:state.gravity width:image.size.width height:image.size.height containerRect:&containerRect outRect:&dstRect];
    dstRect.origin.x += x;
    dstRect.origin.y += y;

    if (self.scaledImageCache == nil) {
        self.scaledImageCache = [self resizeImage:image toWidth:dstRect.size.width height:dstRect.size.height];
    }
    UIGraphicsPushContext(context);
    //flip the orientation of the drawable image
    CGContextDrawImage(context, dstRect, self.scaledImageCache.CGImage);
    UIGraphicsPopContext();
}

- (CGSize)intrinsicSize {
    return self.internalConstantState.image.size;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    IDLBitmapDrawableConstantState *state = self.internalConstantState;
    [super inflateWithElement:element];
    NSMutableDictionary *dictionary = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    NSString *bitmapIdentifier = dictionary[@"src"];
    if (bitmapIdentifier != nil) {
        IDLResourceManager *resMgr = [IDLResourceManager currentResourceManager];
        UIImage *image = [resMgr imageForIdentifier:bitmapIdentifier];
        state.image = image;
    } else {
        NSLog(@"<bitmap> requires a valid src attribute");
    }
    
    NSString *gravityValue = dictionary[@"gravity"];
    if (gravityValue != nil) {
        state.gravity = [IDLGravity gravityFromAttribute:gravityValue];
    }
}

- (CGSize)minimumSize {
    IDLBitmapDrawableConstantState *state = self.internalConstantState;
    if ([state.image respondsToSelector:@selector(capInsets)]) {
        UIEdgeInsets insets = state.image.capInsets;
        if (!UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero)) {
            return CGSizeMake(insets.left + insets.right, insets.top + insets.bottom);
        }
    }
    return [super minimumSize];
}

- (BOOL)hasPadding {
    return self.internalConstantState.image.hasNinePatchPaddings;
}

- (UIEdgeInsets)padding {
    return self.internalConstantState.image.ninePatchPaddings;
}

- (void)onBoundsChangeToRect:(CGRect)bounds {
    [super onBoundsChangeToRect:bounds];
    self.scaledImageCache = nil;
}

- (IDLDrawableConstantState *)constantState {
    return self.internalConstantState;
}

@end
