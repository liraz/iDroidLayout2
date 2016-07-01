//
//  UIImage+IDLNinePatch.m
//  iDroidLayout2
//
//  Created by Tom Quist on 19.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "UIImage+IDLNinePatch.h"
#import <objc/runtime.h>

@implementation UIImage (IDLNinePatch)

static char ninePatchPaddingsKey;

+ (UIImage *)idl_ninePatchImageFromImage:(UIImage *)image {
    UIEdgeInsets capInsets = UIEdgeInsetsZero;
    UIEdgeInsets padding = UIEdgeInsetsZero;
    BOOL hasPadding = FALSE;
    [image idl_ninePatchCapInsets:&capInsets padding:&padding hasPadding:&hasPadding];
    UIImage *ninePatchImage = [self resizableImageFromNinePatchImage:image withInsets:capInsets];
    if (hasPadding) {
        objc_setAssociatedObject(ninePatchImage,
                                 &ninePatchPaddingsKey,
                                 [NSValue valueWithUIEdgeInsets:padding],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ninePatchImage;
}

+ (BOOL)isNinePatchImageFile:(NSString *)fileName {
    static NSArray *ninePatchSuffixes = nil;
    if (ninePatchSuffixes == nil) {
        ninePatchSuffixes = @[@".9.png", @".9@2x.png", @"@2x.9.png"];
    }
    BOOL ret = FALSE;
    for (NSString *suffix in ninePatchSuffixes) {
        if ([fileName hasSuffix:suffix]) {
            ret = TRUE;
            break;
        }
    }
    return ret;
}

- (BOOL)hasNinePatchPaddings {
    return objc_getAssociatedObject(self, &ninePatchPaddingsKey) != nil;
}

- (UIEdgeInsets)ninePatchPaddings {
    NSValue *value = objc_getAssociatedObject(self, &ninePatchPaddingsKey);
    UIEdgeInsets ret = UIEdgeInsetsZero;
    if (value != nil) {
        ret = [value UIEdgeInsetsValue];
    }
    return ret;
}

- (void)writePixelMaskForRect:(CGRect)rect toBuffer:(unsigned char *)buffer {
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGContextRef context = CGBitmapContextCreate(buffer, rect.size.width, rect.size.height, 8, rect.size.width, NULL, (CGBitmapInfo)kCGImageAlphaOnly);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(croppedImageRef), CGImageGetHeight(croppedImageRef)), croppedImageRef);
    CGImageRelease(croppedImageRef);
    CGContextRelease(context);
}

- (BOOL)idl_startAndEndFromBuffer:(unsigned char *)buffer length:(long)length startRef:(CGFloat *)start endRef:(CGFloat *)end {
    unsigned char threshold = 0x7f;
    BOOL searchForEnd = FALSE;
    for (int i=0; i<length; i++) {
        unsigned char color = buffer[i];
        if (color > threshold) {
            (*start) = i;
            searchForEnd = TRUE;
            break;
        }
    }
    if (searchForEnd) {
        for (int i=(int)length-1; i>=0; i--) {
            unsigned char color = buffer[i];
            if (color > threshold) {
                (*end) = length - i - 1;
                break;
            }
        }
    }
    return searchForEnd;
}

- (void)idl_ninePatchCapInsets:(UIEdgeInsets *)capInsets padding:(UIEdgeInsets *)padding hasPadding:(BOOL *)hasPadding {
    // CapInsets rects
    CGRect leftRect = CGRectMake(0.f, 0.f, 1.f, self.size.height * self.scale);
    CGRect topRect = CGRectMake(0.f, 0.f, self.size.width * self.scale, 1.f);
    long verticalBufferSize = ceilf(leftRect.size.width) * ceilf(leftRect.size.height);
    long horizontalBufferSize = ceilf(topRect.size.width) * ceilf(topRect.size.height);
    
    // Padding rects
    CGRect rightRect = CGRectMake(self.size.width * self.scale - 1.f, 0.f, 1.f, self.size.height * self.scale);
    CGRect bottomRect = CGRectMake(0.f, self.size.height * self.scale - 1.f, self.size.width * self.scale, 1.f);
    
    // We allocate one single buffer containing all the data:
    // | leftCapInsetLine | topCapInsetLine | rightPaddingLine | bottomPaddingLine |
    long totalBufferSize = 0;
    if (capInsets != NULL) {
        totalBufferSize += verticalBufferSize + horizontalBufferSize;
    }
    if  (padding != NULL) {
        totalBufferSize += verticalBufferSize + horizontalBufferSize;
    }
    if (totalBufferSize > 0) {
        unsigned char *buffer = calloc(totalBufferSize, 1);
        unsigned char *leftBuffer;
        unsigned char *topBuffer;
        unsigned char *rightBuffer;
        unsigned char *bottomBuffer;
        
        if (capInsets != NULL) {
            leftBuffer = buffer;
            topBuffer = leftBuffer + verticalBufferSize;
            rightBuffer = topBuffer + horizontalBufferSize;
            bottomBuffer = rightBuffer + verticalBufferSize;
        } else {
            rightBuffer = buffer;
            bottomBuffer = rightBuffer + verticalBufferSize;
        }
        
        // First write the pixel lines to the buffer...
        if (capInsets != NULL) {
            [self writePixelMaskForRect:leftRect toBuffer:leftBuffer];
            [self writePixelMaskForRect:topRect toBuffer:topBuffer];
        }
        if (padding != NULL) {
            [self writePixelMaskForRect:rightRect toBuffer:rightBuffer];
            [self writePixelMaskForRect:bottomRect toBuffer:bottomBuffer];
        }
        
        // ...then find start and end pixel of the nine patch indicator lines
        if (capInsets != NULL) {
            [self idl_startAndEndFromBuffer:leftBuffer length:verticalBufferSize startRef:&(*capInsets).top endRef:&(*capInsets).bottom];
            [self idl_startAndEndFromBuffer:topBuffer length:horizontalBufferSize startRef:&(*capInsets).left endRef:&(*capInsets).right];
            (*capInsets).top /= self.scale;
            (*capInsets).left /= self.scale;
            (*capInsets).bottom /= self.scale;
            (*capInsets).right /= self.scale;
        }
        if (padding != NULL) {
            BOOL paddingIndicator = [self idl_startAndEndFromBuffer:rightBuffer length:verticalBufferSize startRef:&(*padding).top endRef:&(*padding).bottom];
            paddingIndicator |= [self idl_startAndEndFromBuffer:bottomBuffer length:horizontalBufferSize startRef:&(*padding).left endRef:&(*padding).right];
            (*padding).top /= self.scale;
            (*padding).left /= self.scale;
            (*padding).bottom /= self.scale;
            (*padding).right /= self.scale;
            if (hasPadding != NULL) {
                (*hasPadding)= paddingIndicator;
            }
        }
        free(buffer);
    }
}

+ (UIImage *)idl_imageWithName:(NSString *)name fromBundle:(NSBundle *)bundle {
    UIImage *ret = nil;
    NSString *extension = [name pathExtension];
    if ([extension length] == 0) {
        extension = @"png";
    }
    NSString *fileName = [name stringByDeletingPathExtension];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale >= 2.f) {
        NSString *retinaFileName = [fileName stringByAppendingString:@"@2x"];
        NSURL *retinaImageURL = [bundle URLForResource:retinaFileName withExtension:extension];
        if (retinaImageURL != nil) {
            UIImage *nonScaledImage = [[UIImage alloc] initWithContentsOfFile:[retinaImageURL path]];
            UIImage *retinaImage = nil;
            if (nonScaledImage != nil) {
                if (nonScaledImage.scale >= 2.f) {
                    retinaImage = nonScaledImage;
                } else {
                    retinaImage = [[UIImage alloc] initWithCGImage:nonScaledImage.CGImage scale:2.f orientation:nonScaledImage.imageOrientation];
                }
            }
            if (retinaImage != nil) {
                if ([self isNinePatchImageFile:[retinaImageURL lastPathComponent]]) {
                    ret = [self idl_ninePatchImageFromImage:retinaImage];
                } else {
                    ret = retinaImage;
                }
            }
        }
    }
    
    if (ret == nil) {
        NSURL *imageURL = [bundle URLForResource:fileName withExtension:extension];
        if (imageURL != nil) {
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:imageURL.path];
            if ([self isNinePatchImageFile:[imageURL lastPathComponent]]) {
                ret = [self idl_ninePatchImageFromImage:image];
            } else {
                ret = image;
            }
        } else {
            NSString *retinaFileName = [fileName stringByAppendingString:@"@2x"];
            NSURL *retinaImageURL = [bundle URLForResource:retinaFileName withExtension:extension];
            if (retinaImageURL != nil) {
                UIImage *nonScaledImage = [[UIImage alloc] initWithContentsOfFile:[retinaImageURL path]];
                UIImage *retinaImage = nil;
                if (nonScaledImage != nil) {
                    if (nonScaledImage.scale >= 2.f) {
                        retinaImage = nonScaledImage;
                    } else {
                        retinaImage = [[UIImage alloc] initWithCGImage:nonScaledImage.CGImage scale:2.f orientation:nonScaledImage.imageOrientation];
                    }
                }
                if (retinaImage != nil) {
                    if ([self isNinePatchImageFile:[retinaImageURL lastPathComponent]]) {
                        ret = [self idl_ninePatchImageFromImage:retinaImage];
                    } else {
                        ret = retinaImage;
                    }
                }
            }
        }
    }
    return ret;
}

+ (UIImage *)resizableImageFromNinePatchImage:(UIImage *)image withInsets:(UIEdgeInsets)insets {
    CGRect imageRect = CGRectMake(1, 1, image.size.width * image.scale - 2, image.size.height * image.scale - 2);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, imageRect);
    UIImage *nonScaledImage = [[UIImage alloc] initWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    UIImage *resizableImage = nil;
    if ([nonScaledImage respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
        resizableImage = [nonScaledImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    } else if ([nonScaledImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        resizableImage = [nonScaledImage resizableImageWithCapInsets:insets];
    } else if ([nonScaledImage respondsToSelector:@selector(stretchableImageWithLeftCapWidth:topCapHeight:)]) {
        resizableImage = [nonScaledImage stretchableImageWithLeftCapWidth:insets.left topCapHeight:insets.top];
    }
    return resizableImage;
}

@end
