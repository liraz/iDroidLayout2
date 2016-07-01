//
//  IDLColorStateItem.m
//  iDroidLayout2
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLColorStateItem.h"
#import "IDLResourceStateItem+IDL_Internal.h"
#import "IDLResourceManager.h"
#import "UIColor+IDL_ColorParser.h"

@interface IDLColorStateItem ()

@property (nonatomic, strong) NSString *resourceIdentifier;

@end

@implementation IDLColorStateItem


- (instancetype)initWithControlState:(UIControlState)controlState colorResourceIdentifier:(NSString *)resourceIdentifier {
    self = [super initWithControlState:controlState];
    if (self) {
        self.resourceIdentifier = resourceIdentifier;
    }
    return self;
}

- (UIColor *)color {
    UIColor *ret = nil;
    if ([[IDLResourceManager currentResourceManager] isValidIdentifier:self.resourceIdentifier]) {
        ret = [[IDLResourceManager currentResourceManager] colorForIdentifier:self.resourceIdentifier];
    } else {
        ret = [UIColor colorFromIDLColorString:self.resourceIdentifier];
    }
    return ret;
}

@end
