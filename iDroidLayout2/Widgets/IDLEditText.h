//
//  IDLEditText.h
//  iDroidLayout2
//
//  Created by Tom Quist on 03.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDLEditText : UITextField <UITextFieldDelegate>

@property (nonatomic, assign) UIControlContentVerticalAlignment contentVerticalAlignment;
@property (nonatomic) NSString* rawInputType;

@end
