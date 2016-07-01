//
//  LayoutInflater.m
//  iDroidLayout2
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLayoutInflater.h"
#import "IDLXMLCache.h"
#import "UIView+IDL_Layout.h"
#import "UIView+IDL_ViewGroup.h"
#import "TBXML.h"
#import "IDLLayoutParams.h"
#import "IDLBaseViewFactory.h"
#import "IDLResourceManager.h"
#import "TBXML+IDL.h"
#import "IDLResourceManager+IDL_Internal.h"

#define TAG_MERGE @"merge"
#define TAG_INCLUDE @"include"
#define INCLUDE_ATTRIBUTE_LAYOUT @"layout"

@implementation IDLLayoutInflater

@synthesize viewFactory = _viewFactory;

+ (NSMutableDictionary *)attributesFromXMLElement:(TBXMLElement *)element reuseDictionary:(NSMutableDictionary *)dict actionTarget:(id)actionTarget {
    dict = [TBXML attributesFromXMLElement:element reuseDictionary:dict];
    // Apply style
    NSString *styleAttribute = dict[@"style"];
    if ([styleAttribute length] > 0) {
        IDLStyle *style = [[IDLResourceManager currentResourceManager] styleForIdentifier:styleAttribute];
        if (style != nil) {
            NSDictionary *styleAttributes = style.attributes;
            for (NSString *name in [styleAttributes allKeys]) {
                if (dict[name] == nil) {
                    dict[name] = styleAttributes[name];
                }
            }
        }
        [dict removeObjectForKey:@"style"];
    }
    if (actionTarget != nil) {
        [dict setValue:actionTarget forKey:IDLViewAttributeActionTarget];
    } else {
        [dict removeObjectForKey:IDLViewAttributeActionTarget];
    }
    return dict;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _viewFactory = [[IDLBaseViewFactory alloc] init];
    }
    return self;
}

- (UIView *)createViewFromTag:(NSString *)name withAttributes:(NSDictionary *)attrs intoParentView:(UIView *)parent {
    if ([name isEqualToString:@"view"]) {
        name = attrs[@"class"];
    }
    UIView *ret = nil;
    @try {
        ret = [self.viewFactory onCreateViewWithName:name attributes:attrs];
    }
    @catch (NSException *exception) {
        NSLog(@"Could not initialize class for view with name %@. Exception: %@", name, exception);
        @throw exception;
    }
    return ret;
}

- (void)parseIncludeWithXmlElement:(TBXMLElement *)element parentView:(UIView *)parentView attributes:(NSMutableDictionary *)attrs {
    if (!parentView.isViewGroup) {
        NSLog(@"<include /> can only be used in view groups");
        return;
    }
    
    NSString *layoutToInclude = attrs[INCLUDE_ATTRIBUTE_LAYOUT];
    NSError *error = nil;
    if (layoutToInclude == nil) {
        NSLog(@"You must specifiy a layout in the include tag: <include layout=\"@layout/layoutName\" />");
    } else {
        NSURL *url = [[IDLResourceManager currentResourceManager] layoutURLForIdentifier:layoutToInclude];
        if (url == nil) {
            NSLog(@"You must specifiy a valid layout reference. The layout ID %@ is not valid.", layoutToInclude);
        } else {
            TBXML *xml = [[IDLResourceManager currentResourceManager].xmlCache xmlForUrl:url error:&error];
            //[TBXML newTBXMLWithXMLData:[NSData dataWithContentsOfURL:url] error:&error];
            if (error) {
                NSLog(@"Cannot include layout %@: %@ %@", layoutToInclude, [error localizedDescription], [error userInfo]);
            } else {
                TBXMLElement *rootElement = xml.rootXMLElement;
                NSString *elementName = [TBXML elementName:rootElement];
                
                NSMutableDictionary *childAttrs = [IDLLayoutInflater attributesFromXMLElement:rootElement reuseDictionary:nil actionTarget:self.actionTarget];
                if ([elementName isEqualToString:TAG_MERGE]) {
                    [self rInflateWithXmlElement:rootElement->firstChild parentView:parentView attributes:childAttrs finishInflate:TRUE];
                } else {
                    UIView *temp = [self createViewFromTag:elementName withAttributes:childAttrs intoParentView:parentView];

                    // We try to load the layout params set in the <include /> tag. If
                    // they don't exist, we will rely on the layout params set in the
                    // included XML file.
                    // During a layoutparams generation, a runtime exception is thrown
                    // if either layout_width or layout_height is missing. We catch
                    // this exception and set localParams accordingly: true means we
                    // successfully loaded layout params from the <include /> tag,
                    // false means we need to rely on the included layout params.
                    IDLLayoutParams *layoutParams = [parentView generateLayoutParamsFromAttributes:attrs];
                    BOOL validLayoutParams = [parentView checkLayoutParams:layoutParams];
                    if (!validLayoutParams && [parentView respondsToSelector:@selector(generateLayoutParamsFromAttributes:)]) {
                        layoutParams = [parentView generateLayoutParamsFromAttributes:childAttrs];
                    } else if (!validLayoutParams) {
                        layoutParams = [parentView generateDefaultLayoutParams];
                    }
                    temp.layoutParams = layoutParams;
                    
                    // Inflate all children
                    if (rootElement->firstChild != NULL) {
                        [self rInflateWithXmlElement:rootElement->firstChild parentView:temp attributes:childAttrs finishInflate:TRUE];
                    }
                    
                    // Attempt to override the included layout's id with the
                    // one set on the <include /> tag itself.
                    NSString *overwriteIdentifier = attrs[@"id"];
                    if (overwriteIdentifier != nil) {
                        temp.identifier = overwriteIdentifier;
                    }
                    
                    // While we're at it, let's try to override visibility.
                    NSString *overwriteVisibility = attrs[@"visibility"];
                    if (overwriteVisibility != nil) {
                        temp.visibility = IDLViewVisibilityFromString(overwriteVisibility);
                    }
                    [parentView addSubview:temp];
                }
            }
        }
    }
}

- (void)rInflateWithXmlElement:(TBXMLElement *)element parentView:(UIView *)parentView attributes:(NSMutableDictionary *)attrs finishInflate:(BOOL)finishInflate {
    do {
        NSString *tagName = [TBXML elementName:element];
        NSMutableDictionary *childAttrs = [IDLLayoutInflater attributesFromXMLElement:element reuseDictionary:attrs actionTarget:self.actionTarget];
        if ([tagName isEqualToString:TAG_INCLUDE]) {
            // Include other resource
            
            [self parseIncludeWithXmlElement:element parentView:parentView attributes:childAttrs];
            
            
        } else {
            // Create view from element and attach to parent
            
            UIView *view = [self createViewFromTag:tagName withAttributes:childAttrs intoParentView:parentView];
            IDLLayoutParams *layoutParams = nil;
            if ([parentView respondsToSelector:@selector(generateLayoutParamsFromAttributes:)]) {
                layoutParams = [parentView generateLayoutParamsFromAttributes:attrs];
            } else {
                layoutParams = [parentView generateDefaultLayoutParams];
            }
            view.layoutParams = layoutParams;
            if (element->firstChild != NULL) {
                [self rInflateWithXmlElement:element->firstChild parentView:view attributes:attrs finishInflate:TRUE];
            }
            [parentView addView:view];
        }
    } while ((element = element->nextSibling));
    if (finishInflate) [parentView onFinishInflate];
}

- (UIView *)inflateParser:(TBXML *)parser intoRootView:(UIView *)rootView attachToRoot:(BOOL)attachToRoot {
    UIView *ret = nil;
    if (rootView != nil && !rootView.isViewGroup) {
        NSLog(@"rootView must be ViewGroup");
        return nil;
    }
    
    TBXMLElement *rootElement = parser.rootXMLElement;
    NSString *elementName = [TBXML elementName:rootElement];
    NSMutableDictionary *attrs = [IDLLayoutInflater attributesFromXMLElement:rootElement reuseDictionary:nil actionTarget:self.actionTarget];
    if ([elementName isEqualToString:TAG_MERGE]) {
        if (rootView == nil || !attachToRoot) {
            NSLog(@"<merge /> can be used only with a valid ViewGroup root and attachToRoot=true");
            return nil;;
        } else if (rootElement->firstChild != NULL) {
            [self rInflateWithXmlElement:rootElement->firstChild parentView:rootView attributes:attrs finishInflate:TRUE];
        }
        ret = rootView;
    } else {
        UIView *temp = [self createViewFromTag:elementName withAttributes:attrs intoParentView:rootView];
        
        if (rootView != nil) {
            IDLLayoutParams *layoutParams = nil;
            if ([rootView respondsToSelector:@selector(generateLayoutParamsFromAttributes:)]) {
                layoutParams = [rootView generateLayoutParamsFromAttributes:attrs];
            } else {
                layoutParams = [rootView generateDefaultLayoutParams];
            }
            temp.layoutParams = layoutParams;
        }
        if (rootElement->firstChild != NULL) {
            [self rInflateWithXmlElement:rootElement->firstChild parentView:temp attributes:attrs finishInflate:TRUE];
        }
        if (attachToRoot && rootView != nil) {
            [rootView addSubview:temp];
            ret = rootView;
        } else {
            ret = temp;
        }
    }
    return ret;
}

- (UIView *)inflateURL:(NSURL *)url intoRootView:(UIView *)rootView attachToRoot:(BOOL)attachToRoot {
    CFTimeInterval methodStart = CACurrentMediaTime();
    NSError *error = nil;
    TBXML *xml = [[IDLResourceManager currentResourceManager].xmlCache xmlForUrl:url error:&error];
    //[[TBXML newTBXMLWithXMLData:[NSData dataWithContentsOfURL:url] error:&error] autorelease];
    if (error) {
        NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
        return nil;
    }
    UIView *ret = [self inflateParser:xml intoRootView:rootView attachToRoot:attachToRoot];
    NSTimeInterval methodFinish = CACurrentMediaTime();
    NSTimeInterval executionTime = methodFinish - methodStart;
    NSLog(@"Inflation of %@ took %.2fms", [url absoluteString], executionTime*1000);
    return ret;

}

- (UIView *)inflateResource:(NSString *)resource intoRootView:(UIView *)rootView attachToRoot:(BOOL)attachToRoot {
    NSError *error = nil;
    TBXML *xml = [TBXML tbxmlWithXMLFile:resource error:&error];
    if (error) {
        NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
        return nil;
    }
    return [self inflateParser:xml intoRootView:rootView attachToRoot:attachToRoot];
}

@end
