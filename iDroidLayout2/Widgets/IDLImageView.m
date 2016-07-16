//
// Created by mac on 7/16/16.
// Copyright (c) 2016 Tom Quist. All rights reserved.
//

#import "IDLImageView.h"

@implementation IDLImageView {

}

- (void)setupFromAttributes:(NSDictionary *)attrs {
    [super setupFromAttributes:attrs];

    self.imageView = [[UIImageView alloc] initWithAttributes:attrs];
    [self addView:self.imageView];
}

@end