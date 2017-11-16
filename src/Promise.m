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
 * LastModified: Nov 16, 2017                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import "Promise.h"

NSString *const PromiseErrorDomain = @"PromiseErrorDomain";

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

NSError * promise_error(PromiseError code, NSString *errMsg) {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errMsg
                                                         forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:PromiseErrorDomain code:code userInfo:userInfo];
}

NSError * promise_exception_to_error(NSException *e) {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              e.name, NSLocalizedDescriptionKey,
                              e.reason, NSLocalizedFailureReasonErrorKey,
                              nil];
    return [NSError errorWithDomain:PromiseErrorDomain code:PromiseExceptionError userInfo:userInfo];
}

void promise_call(Promise * next, id(^callback)(id), id x) {
    dispatch_async([Promise dispatchQueue], ^{
        @try {
            id result = callback(x);
            if ([result isKindOfClass:[NSException class]]) {
                [next reject:promise_exception_to_error(result)];
            }
            else if ([result isKindOfClass:[NSError class]]) {
                [next reject:result];
            }
            else {
                [next resolve:result];
            }
        }
        @catch (NSException *e) {
            [next reject:promise_exception_to_error(e)];
        }
    });
}

void promise_reject(Promise * next, id(^onreject)(id), id e) {
    if (onreject != nil) {
        promise_call(next, onreject, e);
    }
    else {
        [next reject:e];
    }
}

void promise_resolve(Promise * next, id(^onfulfill)(id), id x) {
    if (onfulfill != nil) {
        promise_call(next, onfulfill, x);
    }
    else {
        [next resolve:x];
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

static dispatch_queue_t promise_queue = NULL;

- (id) init {
    if (self = [super init]) {
        _subscribers = [NSMutableArray array];
    }
    return self;
    
}

- (id) init:(id (^)(void))computation {
    if (self = [self init]) {
        __block Promise *promise = self;
        dispatch_async([Promise dispatchQueue], ^{
            @try {
                id result = computation();
                if ([result isKindOfClass:[NSException class]]) {
                    [promise reject:promise_exception_to_error(result)];
                }
                else if ([result isKindOfClass:[NSError class]]) {
                    [promise reject:result];
                }
                else {
                    [promise resolve:result];
                }
            }
            @catch (NSException *e) {
                [promise reject:promise_exception_to_error(e)];
            }
        });
    }
    return self;
}

+ (void) setDispatchQueue:(dispatch_queue_t)queue {
    promise_queue = queue;
}

+ (dispatch_queue_t) dispatchQueue {
    if (promise_queue != NULL) {
        return promise_queue;
    }
    return PROMISE_QUEUE;
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
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, [Promise dispatchQueue]);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), 0, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(timer);
        [promise resolve:value];
    });
    dispatch_resume(timer);
    return promise;
}

+ (Promise *) delayed:(NSTimeInterval)duration block:(id (^)(void))computation {
    Promise * promise = [Promise promise];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, [Promise dispatchQueue]);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), 0, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(timer);
        @try {
            id result = computation();
            if ([result isKindOfClass:[NSException class]]) {
                [promise reject:promise_exception_to_error(result)];
            }
            else if ([result isKindOfClass:[NSError class]]) {
                [promise reject:result];
            }
            else {
                [promise resolve:result];
            }
        }
        @catch (NSException *e) {
            [promise reject:promise_exception_to_error(e)];
        }
    });
    dispatch_resume(timer);
    return promise;
}

+ (Promise *) sync:(id (^)(void))computation {
    @try {
        id result = computation();
        if ([result isKindOfClass:[NSException class]]) {
            return [Promise error:promise_exception_to_error(result)];
        }
        else if ([result isKindOfClass:[NSError class]]) {
            return [Promise error:result];
        }
        else {
            return [Promise value:result];
        }
    }
    @catch (NSException *e) {
        return [Promise error:promise_exception_to_error(e)];
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
        [[Promise toPromise:element] done: ^(id value) {
            @synchronized (promise) {
                result[i] = value;
                if (--count == 0) {
                    [promise resolve:result];
                }
            }
        } fail:^(id e) {
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
    if (n == 0) {
        return [Promise error: promise_error(PromiseIllegalArgumentError,
                                             @"any(): array must not be empty")];
    }
    __block int64_t count = n;
    __block Promise * promise = [Promise promise];
    for (NSUInteger i = 0; i < n; ++i) {
        [[Promise toPromise:array[i]] done:^(id value) {
            [promise resolve: value];
        } fail:^(id e) {
            @synchronized (promise) {
                if (--count == 0) {
                    [promise reject:promise_error(PromiseRuntimeError,
                                                  @"any(): all promises failed")];
                }
            }
        }];
    }
    return promise;
}

+ (Promise *) each:(id (^)(id, NSUInteger))handler with:(NSArray *)array {
    return [[Promise all:array] done:^(NSArray * array) {
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

- (PromiseState) getState {
    return (PromiseState)_state;
}

- (void) resolve:(id)result {
    if (result == self) {
        [self reject:promise_error(PromiseTypeError, @"Self resolution")];
    }
    else if ([Promise isPromise:result]) {
        [result fill:self];
    }
    else {
        @synchronized(_subscribers) {
            if (_state == PENDING) {
                _state = FULFILLED;
                _result = result;
                while ([_subscribers count] > 0) {
                    Subscriber * subscriber = [_subscribers objectAtIndex:0];
                    [_subscribers removeObjectAtIndex:0];
                    promise_resolve(subscriber.next, subscriber.onfulfill, result);
                }
            }
        }
    }
}

- (void) reject:(id)reason {
    @synchronized(_subscribers) {
        if (_state == PENDING) {
            _state = REJECTED;
            _reason = reason;
            while ([_subscribers count] > 0) {
                Subscriber * subscriber = [_subscribers objectAtIndex:0];
                [_subscribers removeObjectAtIndex:0];
                promise_reject(subscriber.next, subscriber.onreject, reason);
            }
        }
    }
}

- (Promise *) then:(id (^)(id))onfulfill catch:(id (^)(NSError *))onreject {
    Promise * next = [Promise promise];
    @synchronized(_subscribers) {
        if (_state == FULFILLED) {
            promise_resolve(next, onfulfill, _result);
        }
        else if (_state == REJECTED) {
            promise_reject(next, onreject, _reason);
        }
        else {
            [_subscribers addObject:[Subscriber subscriber:next success:onfulfill fail:onreject]];
        }
    }
    return next;
}

- (Promise *) then:(id (^)(id))onfulfill {
    return [self then:onfulfill catch:nil];
}

- (Promise *) done:(void (^)(id))onfulfill fail:(void (^)(NSError *))onreject {
    return [self then: (onfulfill == nil) ? nil : ^id(id result) {
        onfulfill(result);
        return nil;
    } catch: (onreject == nil) ? nil : ^id(NSError * reason) {
        onreject(reason);
        return nil;
    }];
}

- (Promise *) done:(void (^)(id))onfulfill {
    return [self done:onfulfill fail:nil];
}

- (Promise *) catch:(id (^)(NSError *))onreject with:(BOOL (^)(NSError *))test {
    if (test != nil) {
        return [self then:nil catch:^id(NSError * reason) {
            if (test(reason)) {
                return [self then:nil catch:onreject];
            }
            return reason;
        }];
    }
    return [self then:nil catch:onreject];
}

- (Promise *) catch:(id (^)(NSError *))onreject {
    return [self then:nil catch:onreject];
}

- (Promise *) fail:(void (^)(NSError *))onreject {
    return [self done:nil fail:onreject];
}

- (Promise *) whenComplete:(void (^)(void))action {
    return [self then:^id(id result) {
        action();
        return result;
    } catch:^id(NSError * reason) {
        action();
        return reason;
    }];
}

- (Promise *) complete:(id (^)(id))oncomplete {
    return [self then:oncomplete catch:oncomplete];
}

- (Promise *) always:(void (^)(id))oncomplete {
    return [self done:oncomplete fail:oncomplete];
}

- (void) fill:(Promise *)promise {
    [self done:^(id result) {
        [promise resolve:result];
    } fail:^(NSError * reason) {
        [promise reject:reason];
    }];
}

- (Promise *) timeout:(NSTimeInterval)duration with:(id)reason {
    Promise * promise = [Promise promise];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, [Promise dispatchQueue]);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), 0, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(timer);
        if (reason == nil) {
            [promise reject:promise_error(PromiseTimeoutError, @"timeout")];
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
    [self done:^(id result) {
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, [Promise dispatchQueue]);
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), 0, 0);
        dispatch_source_set_event_handler(timer, ^{
            dispatch_source_cancel(timer);
            [promise resolve:result];
        });
        dispatch_resume(timer);
    } fail:^(id reason) {
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

- (Promise *) wait {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [self always:^(id result) {
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return self;
}

@end
