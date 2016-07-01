//
//  IDLResourceValueSet.h
//  iDroidLayout2
//
//  Created by Tom Quist on 14.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDLStyle.h"

@interface IDLResourceValueSet : NSObject

- (NSArray *)integerArrayForName:(NSString *)name;
- (IDLStyle *)styleForName:(NSString *)name;
- (NSString *)stringForName:(NSString *)name;
- (UIColor *)colorForName:(NSString *)name;
- (NSArray *)stringArrayForName:(NSString *)name;
+ (IDLResourceValueSet *)createFromXMLData:(NSData *)data;
+ (IDLResourceValueSet *)createFromXMLURL:(NSURL *)url;

@end
