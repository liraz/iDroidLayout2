//
//  IDLEditText.m
//  iDroidLayout2
//
//  Created by Tom Quist on 03.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLEditText.h"
#import "UIView+IDL_Layout.h"
#import "Categories/UITextField+IDL_View.h"

@implementation IDLEditText {
    BOOL _appliedJumpFix;
}

@synthesize contentVerticalAlignment = _contentVerticalAlignment;

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:)
                                                 name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEndEditing:)
                                                 name:UITextFieldTextDidEndEditingNotification object:nil];
}

- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    IDLLayoutMeasureSpecMode widthMode = widthMeasureSpec.mode;
    IDLLayoutMeasureSpecMode heightMode = heightMeasureSpec.mode;
    CGFloat widthSize = widthMeasureSpec.size;
    CGFloat heightSize = heightMeasureSpec.size;
    
    IDLLayoutMeasuredSize measuredSize;
    measuredSize.width.state = IDLLayoutMeasuredStateNone;
    measuredSize.height.state = IDLLayoutMeasuredStateNone;
    UIEdgeInsets padding = self.padding;

    bool bHasAttributes = [self respondsToSelector:@selector(attributedText)];
    
    if (widthMode == IDLLayoutMeasureSpecModeExactly) {
        measuredSize.width.size = widthSize;
    } else {
        CGSize size;
        size = [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: self.font}
                                       context:nil].size;
        // correction for "boundingRectWithSize" missing some padding from text width
        size.width = size.width + padding.right;

        if (bHasAttributes) {
            CGSize attributedTextSize = [self.attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                                          context:nil].size;
            if (attributedTextSize.width > size.width) {
                size = attributedTextSize;
            }
        }

        measuredSize.width.size = ceilf(size.width) + padding.left + padding.right;
        if (widthMode == IDLLayoutMeasureSpecModeAtMost) {
            measuredSize.width.size = MIN(measuredSize.width.size, widthSize);
        }
    }
    CGSize minSize = self.minSize;
    measuredSize.width.size = MAX(measuredSize.width.size, minSize.width);
    
    if (heightMode == IDLLayoutMeasureSpecModeExactly) {
        measuredSize.height.size = heightSize;
    } else {
        CGSize size;
        size = [self.text boundingRectWithSize:CGSizeMake(measuredSize.width.size - padding.left - padding.right, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: self.font}
                                       context:nil].size;

        if (bHasAttributes) {
            CGSize attributedTextSize = [self.attributedText boundingRectWithSize:CGSizeMake(measuredSize.width.size - padding.left - padding.right, CGFLOAT_MAX)
                                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                                          context:nil].size;
            if (attributedTextSize.height > size.height) {
                size = attributedTextSize;
            }
        }

        measuredSize.height.size = MAX(ceilf(size.height), self.font.lineHeight) + padding.top + padding.bottom;
        if (heightMode == IDLLayoutMeasureSpecModeAtMost) {
            measuredSize.height.size = MIN(measuredSize.height.size, heightSize);
        }
    }
    measuredSize.height.size = MAX(measuredSize.height.size, minSize.height);
    
    [self setMeasuredDimensionSize:measuredSize];
}


- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
    [super setContentVerticalAlignment:contentVerticalAlignment];
    _contentVerticalAlignment = contentVerticalAlignment;
    [self setNeedsDisplay];
}

- (void)setRawInputType:(NSString *)inputType {
    [self setInputType:inputType];
}

- (void)textChanged:(NSNotification *)notification {
    if(self.layoutParams.width == IDLLayoutParamsSizeWrapContent) {
        [self requestLayout];
    }
}

- (void)textEndEditing:(NSNotification *)notification {
    if (!_appliedJumpFix && self.text.length > 0) {
        // Workaround for jumping text bug
        [self resignFirstResponder];
        [self layoutIfNeeded];

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UITextFieldTextDidEndEditingNotification
                                                      object:nil];

        _appliedJumpFix = YES;
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.padding);
    CGRect rect = [super textRectForBounds:bounds];
    CGFloat rightPadding = self.padding.right;

    CGRect result;
    switch (_contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop:
            result = CGRectMake(rect.origin.x / 2, bounds.origin.y, rect.size.width + rightPadding, rect.size.height);
            break;
        case UIControlContentVerticalAlignmentCenter:
            result = CGRectMake(rect.origin.x / 2, bounds.origin.y + (bounds.size.height - rect.size.height) / 2, rect.size.width + rightPadding, rect.size.height);
            break;
        case UIControlContentVerticalAlignmentBottom:
            result = CGRectMake(rect.origin.x / 2, bounds.origin.y + (bounds.size.height - rect.size.height), rect.size.width + rightPadding, rect.size.height);
            break;
        default:
            result = bounds;
            break;
    }
    return result;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.padding);
    CGRect rect = [super editingRectForBounds:bounds];
    CGRect result;
    switch (_contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop:
            result = CGRectMake(rect.origin.x, bounds.origin.y, rect.size.width, rect.size.height);
            break;
        case UIControlContentVerticalAlignmentCenter:
            result = CGRectMake(rect.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height) / 2, rect.size.width, rect.size.height);
            break;
        case UIControlContentVerticalAlignmentBottom:
            result = CGRectMake(rect.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height), rect.size.width, rect.size.height);
            break;
        default:
            result = bounds;
            break;
    }
    return result;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    bounds = UIEdgeInsetsInsetRect(bounds, self.padding);
    CGRect rect = [super placeholderRectForBounds:bounds];
    CGRect result;
    switch (_contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop:
            result = CGRectMake(rect.origin.x, bounds.origin.y, rect.size.width, rect.size.height);
            break;
        case UIControlContentVerticalAlignmentCenter:
            result = CGRectMake(rect.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height) / 2, rect.size.width, rect.size.height);
            break;
        case UIControlContentVerticalAlignmentBottom:
            result = CGRectMake(rect.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height), rect.size.width, rect.size.height);
            break;
        default:
            result = bounds;
            break;
    }
    return result;
}


- (void)drawTextInRect:(CGRect)rect {
    CGRect r = [self textRectForBounds:rect];
    [super drawTextInRect:r];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    CGRect r = [self textRectForBounds:rect];
    [super drawPlaceholderInRect:r];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self requestLayout];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
