//
//  SynchronizedPool.m
//  iDroidLayout2
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLSynchronizedPool.h"

@implementation IDLSynchronizedPool {
    BOOL _hasBlockOwnership;
    id<IDLPool> _pool;
    id _lock;
}


- (instancetype)initWithPool:(id<IDLPool>)pool lock:(id)lock takeLockOwnership:(BOOL)takeLockOwnership {
    self = [super init];
    if (self) {
        _pool = pool;
        _lock = lock;
        _hasBlockOwnership = takeLockOwnership;
    }
    return self;
}

- (instancetype)initWithPool:(id<IDLPool>)pool {
	self = [self initWithPool:pool lock:self takeLockOwnership:FALSE];
	if (self != nil) {
        
	}
	return self;
}

- (id<IDLPoolable>)acquire {
    @synchronized(_lock) {
        return [_pool acquire];
    }
}

- (void)releaseElement:(id<IDLPoolable>)element {
    @synchronized(_lock) {
        return [_pool releaseElement:element];
    }
}

@end
