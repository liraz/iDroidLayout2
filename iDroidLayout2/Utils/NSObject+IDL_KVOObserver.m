//
//  NSObject+IDL_KVOObserver.m
//  iDroidLayout2
//
//  Created by Tom Quist on 21.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "NSObject+IDL_KVOObserver.h"
#import <objc/runtime.h>

@interface IDLKVOObserver : NSObject

@property (readwrite, retain) NSString *identifier;
@property (readwrite, copy) IDLKVOObserverBlock observerBlock;
@property (readwrite, assign) id object;
@property (readwrite, retain) NSArray *keyPaths;

@end

@implementation IDLKVOObserver

static void *myContextPointer;

@synthesize identifier = _identifier;
@synthesize observerBlock = _observerBlock;
@synthesize keyPaths = _keyPaths;
@synthesize object = _object;

- (void)dealloc {
    for (NSString *keyPath in self.keyPaths) {
        [self.object removeObserver:self forKeyPath:keyPath];
    }
    self.identifier = nil;
    self.observerBlock = nil;
    self.keyPaths = nil;
}

- (instancetype)initWithIdentifier:(NSString *)identifier object:(id)obj keyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options observerBlock:(IDLKVOObserverBlock)block {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.object = obj;
        self.keyPaths = keyPaths;
        self.observerBlock = block;
        for (NSString *keyPath in keyPaths) {
            [obj addObserver:self forKeyPath:keyPath options:options context:&myContextPointer];
        }
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != &myContextPointer) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    else {
        self.observerBlock(keyPath, object, change);
    }
}

@end


@interface NSObject ()

@property (nonatomic, readonly) NSMutableDictionary *idl_kvoObservers;

@end

@implementation NSObject (IDL_KVOObserver)

static char idl_kvoObserversKey;

- (NSMutableDictionary *)idl_kvoObservers {
    @synchronized(self) {
        NSMutableDictionary *array = objc_getAssociatedObject(self, &idl_kvoObserversKey);
        if (array == nil) {
            array = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self,
                                     &idl_kvoObserversKey,
                                     array,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return array;
    }
}

- (void)idl_removeObserverWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *observers = [self idl_kvoObservers];
    [observers removeObjectForKey:identifier];
}

- (void)idl_addObserver:(IDLKVOObserverBlock)observer withIdentifier:(NSString *)identifier forKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options {
    IDLKVOObserver *observerObject = [[IDLKVOObserver alloc] initWithIdentifier:identifier object:self keyPaths:keyPaths options:options observerBlock:observer];
    [self idl_kvoObservers][identifier] = observerObject;
}

- (BOOL)idl_hasObserverWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *observers = [self idl_kvoObservers];
    return observers[identifier] != nil;
}

- (void)idl_removeAllObservers {
    for (NSString* identifier in self.idl_kvoObservers.allKeys) {
        [self idl_removeObserverWithIdentifier:identifier];
    }
}

@end
