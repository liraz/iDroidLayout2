//
//  IDLTextArea.h
//  iDroidLayout2
//
//  Created by Tom Quist on 03.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDLTextArea : UITextView

@property (nonatomic, strong) NSString* placeholder;
@property (nonatomic, copy) UIColor* placeholderColor;
@property (nonatomic, assign) UIControlContentVerticalAlignment contentVerticalAlignment;

@end
