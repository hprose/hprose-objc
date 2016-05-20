/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * Promise.m                                              *
 *                                                        *
 * Promise for Objective-C.                               *
 *                                                        *
 * LastModified: May 20, 2016                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import "Promise.h"
#import "libkern/OSAtomic.h"

@implementation NSArray (NSArrayFunctional)

- (void) each:(id (^)(id, NSUInteger))handler {
    for (NSUInteger i = 0, n = [self count]; i < n; ++i) {
        handler(self[i], i);
    }
}

- (BOOL) every:(BOOL (^)(id, NSUInteger))handler {
    for (NSUInteger i = 0, n = [self count]; i < n; ++i) {
        if (handler(self[i], i) == NO) return NO;
    }
    return YES;
}

- (BOOL) some:(BOOL (^)(id, NSUInteger))handler {
    for (NSUInteger i = 0, n = [self count]; i < n; ++i) {
        if (handler(self[i], i)) return YES;
    }
    return NO;
}

- (NSArray *) filter:(BOOL (^)(id, NSUInteger))handler {
    NSUInteger n = [self count];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:n];
    for (NSUInteger i = 0; i < n; ++i) {
        if (handler(self[i], i)) [result addObject:self[i]];
    }
    return result;
}

- (NSArray *) map:(id (^)(id, NSUInteger))handler {
    NSUInteger n = [self count];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:n];
    for (NSUInteger i = 0; i < n; ++i) {
        [result addObject: handler(self[i], i)];
    }
    return result;
}

- (id) reduce:(id (^)(id, id, NSUInteger))handler {
    NSUInteger n = [self count];
    if (n == 0) return nil;
    id result = self[0];
    for (NSUInteger i = 1; i < n; ++i) {
        result = handler(result, self[i], i);
    }
    return result;
}

- (id) reduce:(id (^)(id, id, NSUInteger))handler init:(id)value {
    NSUInteger n = [self count];
    if (n == 0) return value;
    id result = value;
    for (NSUInteger i = 0; i < n; ++i) {
        result = handler(result, self[i], i);
    }
    return result;
}

- (id) reduceRight:(id (^)(id, id, NSUInteger))handler {
    NSUInteger n = [self count];
    if (n == 0) return nil;
    id result = self[n - 1];
    for (NSUInteger i = n - 1; i > 0;) {
        --i;
        result = handler(result, self[i], i);
    }
    return result;
}

- (id) reduceRight:(id (^)(id, id, NSUInteger))handler init:(id)value {
    NSUInteger n = [self count];
    if (n == 0) return value;
    id result = value;
    for (NSUInteger i = n; i > 0;) {
        --i;
        result = handler(result, self[i], i);
    }
    return result;
}

@end

#define promiseQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

void promise_call(id(^callback)(id), Promise * next, id x) {
    dispatch_async(promiseQueue, ^{
        @try {
            id result = callback(x);
            [next resolve:result];
        }
        @catch (id e) {
            [next reject:e];
        }
    });
}

void promise_reject(id(^onreject)(id), Promise * next, id e) {
    if (onreject != nil) {
        promise_call(onreject, next, e);
    }
    else {
        [next reject:e];
    }
}

void promise_resolve(Promise * this, id(^onfulfill)(id), id(^onreject)(id), Promise * next, id x) {
    if ([Promise isPromise:x]) {
        if (x == this) {
            promise_reject(onreject, next,
                           [NSException exceptionWithName:@"TypeException"
                                                   reason:@"Self resolution"
                                                 userInfo:nil]);
            return;
        }
        [x last:^(id y) {
            promise_resolve(this, onfulfill, onreject, next, y);
        } catch:^(id e) {
            promise_reject(onreject, next, e);
        }];
    }
    else {
        if (onfulfill != nil) {
            promise_call(onfulfill, next, x);
        }
        else {
            [next resolve:x];
        }
    }
}

@interface Subscriber : NSObject {}

@property (copy, nonatomic) id(^onfulfill)(id);
@property (copy, nonatomic) id(^onreject)(id);
@property Promise * next;

+ (Subscriber *) subscriber:(Promise *)next success:(id (^)(id))onfulfill fail:(id (^)(id))onreject;

@end

@implementation Subscriber


+ (Subscriber *) subscriber:(Promise *)next success:(id (^)(id))onfulfill fail:(id (^)(id))onreject {
    Subscriber * result = [[self alloc] init];
    result.next = next;
    result.onfulfill = onfulfill;
    result.onreject = onreject;
    return result;
}

@end

@implementation Promise

- (id) init:(id (^)(void))computation {
    if (self = [super init]) {
        __block Promise *this = self;
        dispatch_async(promiseQueue, ^{
            @try {
                [this resolve:computation()];
            }
            @catch (id e) {
                [this reject:e];
            }
        });
    }
    return self;
}

+ (Promise *) promise {
    return [[self alloc] init];
}

+ (Promise *) promise:(id (^)(void))computation {
    return [[self alloc] init:computation];
}

+ (Promise *) value:(id)value {
    Promise * promise = [Promise promise];
    [promise resolve:value];
    return promise;
}

+ (Promise *) error:(id)reason {
    Promise * promise = [Promise promise];
    [promise reject:reason];
    return promise;
}

+ (Promise *) delayed:(NSTimeInterval)duration with:(id)value {
    Promise * promise = [Promise promise];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, promiseQueue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), duration * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(timer);
        [promise resolve:value];
    });
    dispatch_resume(timer);
    return promise;
}

+ (Promise *) delayed:(NSTimeInterval)duration block:(id (^)(void))computation {
    Promise * promise = [Promise promise];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, promiseQueue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), duration * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(timer);
        @try {
            [promise resolve:computation()];
        }
        @catch (id e) {
            [promise reject:e];
        }
    });
    dispatch_resume(timer);
    return promise;
}

+ (Promise *) sync:(id (^)(void))computation {
    @try {
        return [Promise value:computation()];
    }
    @catch (id e) {
        return [Promise error:e];
    }
}

+ (BOOL) isPromise:(id)value {
    return [value isKindOfClass:[Promise class]];
}

+ (Promise *) toPromise:(id)value {
    return [Promise isPromise:value] ? (Promise *)value : [Promise value:value];
}

+ (Promise *) all:(NSArray *)array {
    NSUInteger n = [array count];
    if (n == 0) return [Promise value:[NSArray array]];
    __block int64_t count = n;
    __block NSMutableArray * result = [NSMutableArray arrayWithCapacity:n];
    __block Promise * promise = [Promise promise];
    void(^allHandler)(id element, NSUInteger i)  = ^(id element, NSUInteger i) {
        [[Promise toPromise:element] last: ^(id value) {
            result[i] = value;
            if (OSAtomicDecrement64(&count) == 0) {
                [promise resolve:result];
            }
        } catch:^(id e) {
            [promise reject:e];
        }];
    };
    for (NSUInteger i = 0; i < n; ++i) {
        allHandler(array[i], i);
    }
    return promise;
}

+ (Promise *) race:(NSArray *)array {
    NSUInteger n = [array count];
    Promise * promise = [Promise promise];
    for (NSUInteger i = 0; i < n; ++i) {
        [[Promise toPromise:array[i]] fill:promise];
    }
    return promise;
}

+ (Promise *) any:(NSArray *)array {
    NSUInteger n = [array count];
    if (n == 0) return [Promise error:[NSException exceptionWithName:@"IllegalArgumentException"
                                                              reason:@"any(): array must not be empty"
                                                            userInfo:nil]];
    __block int64_t count = n;
    __block Promise * promise = [Promise promise];
    for (NSUInteger i = 0; i < n; ++i) {
        [[Promise toPromise:array[i]] last:^(id value) {
            [promise resolve: value];
        } catch:^(id e) {
            if (OSAtomicDecrement64(&count) == 0) {
                [promise reject:[NSException exceptionWithName:@"RuntimeException"
                                                        reason:@"any(): all promises failed"
                                                      userInfo:nil]];
            }
        }];
    }
    return promise;
}

+ (Promise *) each:(id (^)(id, NSUInteger))handler with:(NSArray *)array {
    return [[Promise all:array] last:^(NSArray * array) {
        [array each:handler];
    }];
}

+ (Promise *) every:(BOOL (^)(id, NSUInteger))handler with:(NSArray *)array {
    return [[Promise all:array] then:^NSNumber *(NSArray * array) {
        return [NSNumber numberWithBool:[array every:handler]];
    }];
}

+ (Promise *) some:(BOOL (^)(id, NSUInteger))handler with:(NSArray *)array {
    return [[Promise all:array] then:^NSNumber *(NSArray * array) {
        return [NSNumber numberWithBool:[array some: handler]];
    }];
}

+ (Promise *) filter:(BOOL (^)(id, NSUInteger))handler with:(NSArray *)array {
    return [[Promise all:array] then:^NSArray *(NSArray * array) {
        return [array filter:handler];
    }];
}

+ (Promise *) map:(id (^)(id, NSUInteger))handler with:(NSArray *)array {
    return [[Promise all:array] then:^NSArray *(NSArray * array) {
        return [array map:handler];
    }];
}

+ (Promise *) reduce:(id (^)(id, id, NSUInteger))handler with:(NSArray *)array {
    return [[Promise all:array] then:^NSArray *(NSArray * array) {
        return [array reduce:handler];
    }];
}

+ (Promise *) reduce:(id (^)(id, id, NSUInteger))handler with:(NSArray *)array init:(id)value {
    return [[Promise all:array] then:^NSArray *(NSArray * array) {
        return [array reduce:handler init:value];
    }];
}

+ (Promise *) reduceRight:(id (^)(id, id, NSUInteger))handler with:(NSArray *)array {
    return [[Promise all:array] then:^NSArray *(NSArray * array) {
        return [array reduceRight:handler];
    }];
}

+ (Promise *) reduceRight:(id (^)(id, id, NSUInteger))handler with:(NSArray *) array init:(id)value {
    return [[Promise all:array] then:^NSArray *(NSArray * array) {
        return [array reduceRight:handler init:value];
    }];
}

- (void) resolve:(id)result {
    if (_state == PENDING) {
        _state = FULFILLED;
        _result = result;
        while ([_subscribers count] > 0) {
            Subscriber * subscriber = [_subscribers objectAtIndex:0];
            [_subscribers removeObjectAtIndex:0];
            promise_resolve(self, subscriber.onfulfill, subscriber.onreject, subscriber.next, result);
        }
    }
}

- (void) reject:(id)reason {
    if (_state == PENDING) {
        _state = REJECTED;
        _reason = reason;
        while ([_subscribers count] > 0) {
            Subscriber * subscriber = [_subscribers objectAtIndex:0];
            [_subscribers removeObjectAtIndex:0];
            if (subscriber.onreject != nil) {
                promise_call(subscriber.onreject, subscriber.next, reason);
            }
            else {
                [subscriber.next reject:reason];
            }
        }
    }
}

- (Promise *) then:(id (^)(id))onfulfill catch:(id (^)(id))onreject {
    if (onfulfill != nil || onreject != nil) {
        Promise * next = [Promise promise];
        if (_state == FULFILLED) {
            promise_resolve(self, onfulfill, onreject, next, _result);
        }
        else if (_state == REJECTED) {
            if (onreject != nil) {
                promise_call(onreject, next, _reason);
            }
            else {
                [next reject:_reason];
            }
        }
        else {
            [_subscribers addObject:[Subscriber subscriber:next success:onfulfill fail:onreject]];
        }
        return next;
    }
    return self;
}

- (Promise *) then:(id (^)(id))onfulfill {
    return [self then:onfulfill catch:nil];
}

- (Promise *) last:(void (^)(id))onfulfill catch:(void (^)(id))onreject {
    return [self then: (onfulfill == nil) ? nil : ^id(id result) {
        onfulfill(result);
        return nil;
    } catch: (onreject == nil) ? nil : ^id(id reason) {
        onreject(reason);
        return nil;
    }];
}

- (Promise *) last:(void (^)(id))onfulfill {
    return [self last:onfulfill catch:nil];
}

- (void) done:(void (^)(id))onfulfill fail:(void (^)(id))onreject {
    [[self last:onfulfill catch:onreject] last:nil catch:^(id reason) {
        dispatch_async(promiseQueue, ^{
            @throw reason;
        });
    }];
}

- (void) done:(void (^)(id))onfulfill {
    [self done:onfulfill fail:nil];
}

- (Promise *) catch:(id (^)(id))onreject with:(BOOL (^)(id))test {
    if (test != nil) {
        return [self then:nil catch:^id(id reason) {
            if (test(reason)) {
                return [self then:nil catch:onreject];
            }
            @throw reason;
        }];
    }
    return [self then:nil catch:onreject];
}

- (Promise *) catch:(id (^)(id))onreject {
    return [self then:nil catch:onreject];
}

- (void) fail:(void (^)(id))onreject {
    [self done:nil fail:onreject];
}

- (Promise *) whenComplete:(void  (^)())action {
    return [self then:^id(id result) {
        action();
        return result;
    } catch:^id(id reason) {
        action();
        @throw reason;
    }];
}

- (Promise *) complete:(id (^)(id))oncomplete {
    return [self then:oncomplete catch:oncomplete];
}

- (void) always:(void (^)(id))oncomplete {
    [self done:oncomplete fail:oncomplete];
}

- (void) fill:(Promise *)promise {
    [self last:^(id result) {
        [promise resolve:result];
    } catch:^(id reason) {
        [promise reject:reason];
    }];
}

- (Promise *) timeout:(NSTimeInterval)duration with:(id)reason {
    Promise * promise = [Promise promise];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, promiseQueue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), duration * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(timer);
        if (reason == nil) {
            [promise reject:[NSException exceptionWithName:@"TimeoutException"
                                                   reason:@"timeout"
                                                 userInfo:nil]];
        }
        else {
            [promise reject:reason];
        }
    });
    [[self whenComplete:^{
        dispatch_source_cancel(timer);
    }] fill:promise];
    dispatch_resume(timer);
    return promise;
}

- (Promise *) timeout:(NSTimeInterval)duration {
    return [self timeout:duration with:nil];
}

- (Promise *) delay:(NSTimeInterval)duration {
    Promise * promise = [Promise promise];
    [self last:^(id result) {
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, promiseQueue);
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), duration * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(timer, ^{
            dispatch_source_cancel(timer);
            [promise resolve:result];
        });
        dispatch_resume(timer);
    } catch:^(id reason) {
        [promise reject:reason];
    }];
    return promise;
}

- (Promise *) tap:(void (^)(id))onfulfilledSideEffect {
    return [self then:^id(id result) {
        onfulfilledSideEffect(result);
        return result;
    }];
}

- (Promise *) all {
    return [self then:^id(NSArray *array) {
        return [Promise all:array];
    }];
}

- (Promise *) race {
    return [self then:^id(NSArray *array) {
        return [Promise race:array];
    }];
}

- (Promise *) any {
    return [self then:^id(NSArray *array) {
        return [Promise any:array];
    }];
}

- (Promise *) each:(id (^)(id element, NSUInteger index))handler {
    return [self then:^id(NSArray *array) {
        return [Promise each:handler with:array];
    }];
}

- (Promise *) every:(BOOL (^)(id element, NSUInteger index))handler {
    return [self then:^id(NSArray *array) {
        return [Promise every:handler with:array];
    }];
}

- (Promise *) some:(BOOL (^)(id element, NSUInteger index))handler {
    return [self then:^id(NSArray *array) {
        return [Promise some:handler with:array];
    }];
}
- (Promise *) filter:(BOOL (^)(id element, NSUInteger index))handler {
    return [self then:^id(NSArray *array) {
        return [Promise filter:handler with:array];
    }];
}

- (Promise *) map:(id (^)(id element, NSUInteger index))handler {
    return [self then:^id(NSArray *array) {
        return [Promise map:handler with:array];
    }];
}

- (Promise *) reduce:(id (^)(id prev, id element, NSUInteger index))handler {
    return [self then:^id(NSArray *array) {
        return [Promise reduce:handler with:array];
    }];
}
- (Promise *) reduce:(id (^)(id prev, id element, NSUInteger index))handler init:(id)value {
    return [self then:^id(NSArray *array) {
        return [Promise reduce:handler with:array init:value];
    }];
}
- (Promise *) reduceRight:(id (^)(id prev, id element, NSUInteger index))handler {
    return [self then:^id(NSArray *array) {
        return [Promise reduceRight:handler with:array];
    }];
    
}
- (Promise *) reduceRight:(id (^)(id prev, id element, NSUInteger index))handler init:(id)value {
    return [self then:^id(NSArray *array) {
        return [Promise reduceRight:handler with:array init:value];
    }];
}

@end
