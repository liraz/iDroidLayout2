//
//  IDLColorStateList.h
//  iDroidLayout2
//
//  Created by Tom Quist on 06.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLResourceStateList.h"
#import "IDLColorStateItem.h"
#import "IDLDrawable.h"

@interface IDLColorStateList : IDLResourceStateList

- (UIColor *)colorForControlState:(UIControlState)controlState defaultColor:(UIColor *)defaultColor;
- (UIColor *)colorForControlState:(UIControlState)controlState;
- (IDLDrawable *)convertToDrawable;

+ (instancetype)createFromXMLData:(NSData *)data;
+ (instancetype)createFromXMLURL:(NSURL *)url;
+ (instancetype)createWithSingleColorIdentifier:(NSString *)colorIdentifier;

@end
