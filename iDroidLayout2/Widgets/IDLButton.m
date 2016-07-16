//
//  IDLButton.m
//  iDroidLayout2
//
//  Created by Tom Quist on 05.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLButton.h"

#import "IDLResourceManager.h"
#import "NSDictionary+IDL_ResourceManager.h"
#import "UIColor+IDL_ColorParser.h"
#import "IDLTextView.h"

@implementation IDLButton

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];

    NSString *drawableLeft = attrs[@"drawableLeft"];
    NSString *drawableRight = attrs[@"drawableRight"];

    if (drawableLeft != nil) {
        IDLDrawableStateList *drawableStateList = [[IDLResourceManager currentResourceManager] drawableStateListForIdentifier:drawableLeft];
        if (drawableStateList != nil) {
            self.drawableLeftImage = [[UIImageView alloc] initWithImage: [drawableStateList imageForControlState:UIControlStateNormal]];
            self.drawableLeftImage.contentMode = UIViewContentModeScaleAspectFit;

            [self addView:self.drawableLeftImage];
        }
    }

    IDLTextView* textLabel = [IDLTextView new];

    NSString *text = attrs[@"text"];
    BOOL hasValidIdentifier = [[IDLResourceManager currentResourceManager] isValidIdentifier:text];
    if (hasValidIdentifier) {
        NSString *title = [[IDLResourceManager currentResourceManager] stringForIdentifier:text];
        textLabel.text = title;
    } else {
        textLabel.text = text;
    }
    [self addView:textLabel];

    NSString *textColor = attrs[@"textColor"];
    if ([textColor length] > 0) {
        IDLColorStateList *colorStateList = [[IDLResourceManager currentResourceManager] colorStateListForIdentifier:textColor];
        if (colorStateList != nil) {
            for (NSInteger i=[colorStateList.items count]-1; i>=0; i--) {
                IDLColorStateItem *item = (colorStateList.items)[i];
                [textLabel setTextColor:item.color];
            }
        } else {
            UIColor *color = [UIColor colorFromIDLColorString:textColor];
            if (color != nil) {
                [textLabel setTextColor:color];
            }
        }
    }

    NSString *fontName = attrs[@"font"];
    NSString *textSize = attrs[@"textSize"];
    if (fontName != nil) {
        CGFloat size = textLabel.font.pointSize;
        if (textSize != nil) size = [textSize floatValue];
        textLabel.font = [UIFont fontWithName:fontName size:size];
    } else if (textSize != nil) {
        CGFloat size = [textSize floatValue];
        textLabel.font = [UIFont systemFontOfSize:size];
    }

    if(drawableRight != nil) {
        IDLDrawableStateList *drawableStateList = [[IDLResourceManager currentResourceManager] drawableStateListForIdentifier:drawableRight];
        if (drawableStateList != nil) {
            self.drawableRightImage = [[UIImageView alloc] initWithImage: [drawableStateList imageForControlState:UIControlStateNormal]];
            self.drawableRightImage.contentMode = UIViewContentModeScaleAspectFit;

            [self addView:self.drawableRightImage];
        }
    }

    NSString *drawablePadding = attrs[@"drawablePadding"];
    if (drawablePadding != nil) {
        CGFloat drawablePaddingValue = [attrs dimensionFromIDLValueForKey: @"drawablePadding"];
        textLabel.padding = UIEdgeInsetsMake(0, drawablePaddingValue, 0, drawablePaddingValue);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];

    // If the hitView is THIS view, return the view that you want to receive the touch instead:
    if (_passTouchesToView != nil) {
        return _passTouchesToView;
    }
    // Else return the hitView (as it could be one of this view's buttons):
    return hitView;
}

@end
