//
//  IDLViewGroupTest.m
//  iDroidLayout2
//
//  Created by Tom Quist on 15.09.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLViewGroupTest.h"
#import "IDLViewAsserts.h"

@implementation IDLViewGroupTest

- (void)setUp {
    [super setUp];
    _rootView = [[IDLLayoutBridge alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
    [inflater inflateResource:@"viewgroupchildren.xml" intoRootView:_rootView attachToRoot:TRUE];
    _group = [[(IDLViewGroup *)_rootView subviews] lastObject];
}

- (void)tearDown {
    _rootView = nil;
    _group = nil;
    [super tearDown];
}

- (void)testAddChild {
    UIView *view = [self createViewWithText:@"1"];
    [_group addView:view];
    XCTAssertEqual((NSUInteger)1, [[_group subviews] count], @"Wrong number of children");
}

- (IDLTextView *)createViewWithText:(NSString *)text {
    IDLTextView *view = [[IDLTextView alloc] initWithFrame:CGRectZero];
    view.text = text;
    view.layoutParams = [[IDLLinearLayoutLayoutParams alloc] initWithWidth:IDLLayoutParamsSizeMatchParent height:IDLLayoutParamsSizeWrapContent];
    return view;
}

- (void)testAddChildAtFront {
    for (int i = 0; i < 24; i++) {
        UIView *view = [self createViewWithText:[NSString stringWithFormat:@"%d", (i + 1)]];
        [_group addView:view];
    }
    
    UIView *view = [self createViewWithText:@"X"];
    [_group addView:view atIndex:0];
    
    XCTAssertEqual((NSUInteger)25, [[_group subviews] count], @"Wrong number of children");
    XCTAssertEqual(view, [[_group subviews] objectAtIndex:0], @"View has not been added at front");
}

- (void)testAddChildInMiddle {
    for (int i = 0; i < 24; i++) {
        UIView *view = [self createViewWithText:[NSString stringWithFormat:@"%d", (i + 1)]];
        [_group addView:view];
    }
    
    UIView *view = [self createViewWithText:@"X"];
    [_group addView:view atIndex:12];
    
    XCTAssertEqual((NSUInteger)25, [[_group subviews] count], @"Wrong number of children");
    XCTAssertEqual(view, [[_group subviews] objectAtIndex:12], @"View has not been added in the middle");
}

- (void)testAddChildren {
    for (int i = 0; i < 24; i++) {
        UIView *view = [self createViewWithText:[NSString stringWithFormat:@"%d", (i + 1)]];
        [_group addView:view];
    }
    XCTAssertEqual((NSUInteger)24, [[_group subviews] count], @"Wrong number of children");
}

- (void)testRemoveChild {
    UIView *view = [self createViewWithText:@"1"];
    [_group addView:view];
    
    [_group removeView:view];
    
    [self assertGroup:_group notContains:view];
    
    XCTAssertEqual((NSUInteger)0, [[_group subviews] count], @"Wrong number of children");
    XCTAssertNil([view superview], @"Superview of remove view is not nil");
}

- (void)testRemoveChildren {
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:24];
    
    for (int i = 0; i < 24; i++) {
        UIView *v = [self createViewWithText:[NSString stringWithFormat:@"%d", (i + 1)]];
        [views addObject:v];
        [_group addView:v];
    }
    
    for (int i = (int)[views count] - 1; i >= 0; i--) {
        UIView *v = [views objectAtIndex:i];
        [_group removeViewAtIndex:i];
        [self assertGroup:_group notContains:v];
        XCTAssertNil([v superview], @"Removed view still has a parent");
    }
    
    XCTAssertEqual((NSUInteger)0, [[_group subviews] count], @"ViewGroup still has subviews");
}

- (void)testRemoveChildAtFront {
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:24];
    
    for (int i = 0; i < 24; i++) {
        UIView *v = [self createViewWithText:[NSString stringWithFormat:@"%d", (i+1)]];
        [views addObject:v];
        [_group addView:v];
    }
    
    UIView *v = [views objectAtIndex:0];
    [_group removeViewAtIndex:0];
    [self assertGroup:_group notContains:v];
    XCTAssertNil([v superview], @"View still has a superview");
    
    XCTAssertEqual([views count] - 1, [[_group subviews] count], @"ViewGroup has the wrong number of subviews");
}

- (void)testRemoveChildInMiddle {
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:24];
    
    for (int i = 0; i < 24; i++) {
        UIView *v = [self createViewWithText:[NSString stringWithFormat:@"%d", (i+1)]];
        [views addObject:v];
        [_group addView:v];
    }
    
    UIView *v = [views objectAtIndex:12];
    [_group removeViewAtIndex:12];
    [self assertGroup:_group notContains:v];
    XCTAssertNil([v superview], @"View still has a superview");
    
    XCTAssertEqual([views count] - 1, [[_group subviews] count], @"ViewGroup has the wrong number of subviews");
}

@end
