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
 * HproseClient.m                                         *
 *                                                        *
 * hprose client for Objective-C.                         *
 *                                                        *
 * LastModified: Jun 3, 2016                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <objc/message.h>
#import <objc/runtime.h>
#import "HproseException.h"
#import "HproseReader.h"
#import "HproseWriter.h"
#import "HproseTags.h"
#import "HproseHelper.h"
#import "HproseClient.h"
#import "HproseClientProxy.h"
#import "libkern/OSAtomic.h"

@implementation HproseClientContext

- (id) init:(HproseClient *)client settings:(HproseInvokeSettings *)settings {
    if (self = [super init]) {
        _client = client;
        _settings = [[HproseInvokeSettings alloc] init];
        _settings.byref = client.byref;
        _settings.simple = client.simple;
        _settings.failswitch = client.failswitch;
        _settings.idempotent = client.idempontent;
        _settings.retry = client.retry;
        _settings.timeout = client.timeout;
        _settings.oneway = NO;
        [settings copyTo:_settings];
    }
    return self;
}

@end

@implementation HproseFilterHandlerManager

- (id) init:(SEL)selector with:(id)delegate {
    if (self = [super init]) {
        _selector = selector;
        _delegate = delegate;
    }
    return self;
}

- (HproseFilterHandlerManager *) use:(HproseFilterHandler)handler {
    ((void (*)(id, SEL, HproseFilterHandler))objc_msgSend)(_delegate, _selector, handler);
    return self;
}

@end

@implementation HproseTopic

- (id) init {
    if (self = [super init]) {
        _handler = nil;
        _callbacks = [NSMutableArray array];
    }
    return self;
}

@end

@interface HproseClient(PrivateMethods)

- (id) syncInvoke:(NSString *)name withArgs:(NSArray *)args settings:(HproseInvokeSettings *)settings;
- (id) asyncInvoke:(NSString *)name withArgs:(NSArray *)args settings:(HproseInvokeSettings *)settings;
- (oneway void) errorHandler:(NSString *)name withException:(NSException *)e settings:(HproseInvokeSettings *)settings;

- (NSData *) outputFilter:(NSData *)request context:(HproseClientContext *)context;
- (NSData *) inputFilter:(NSData *)response context:(HproseClientContext *)context;

- (id) invokeHandler:(NSString *)name withArgs:(NSArray *)args context:(HproseClientContext *)context;
- (id) beforeFilterHandler:(NSData *)request context:(HproseClientContext *)context;
- (id) afterFilterHandler:(NSData *)request context:(HproseClientContext *)context;
- (id) sendAndReceive:(NSData *)request context:(HproseClientContext *)context;
- (id) retry:(NSData *)request context:(HproseClientContext *)context;

- (Promise *) getAutoId;
- (HproseTopic *) getTopic:(NSString *)name id:(int32_t)clientId create:(BOOL)create;
- (void) subscribe:(NSString *)name callback:(void (^)(id))callback resultType:(char)resultType resultClass:(Class)resultClass timeout:(NSTimeInterval)timeout;
- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback resultType:(char)resultType resultClass:(Class)resultClass timeout:(NSTimeInterval)timeout;

@end

@implementation HproseClient

static HproseInvokeSettings *autoIdSettings;

+ (void) initialize {
    if (self == [HproseClient class]) {
        autoIdSettings = [[HproseInvokeSettings alloc] init];
        autoIdSettings.resultType =_C_INT;
        autoIdSettings.simple = YES;
        autoIdSettings.idempotent = YES;
        autoIdSettings.failswitch = YES;
        autoIdSettings.async = YES;
    }
}

+ (id) client {
    return [[self alloc] init];
}

+ (id) client:(NSString *)aUri {
    return [[self alloc] init:aUri];
}

- (id) init {
    if (self = [super init]) {
        filters = [NSMutableArray array];
        invokeHandlers = [NSMutableArray array];
        beforeFilterHandlers = [NSMutableArray array];
        afterFilterHandlers = [NSMutableArray array];
        uris = [NSMutableArray array];
        index = -1;
        self.timeout = 30.0;
        self.retry = 10;
        self.idempontent = NO;
        self.failswitch = NO;
        self.byref = NO;
        self.simple = NO;
        __block HproseClient *client = self;
        defaultInvokeHandler = ^id(NSString *name, NSArray *args, HproseContext *context) {
            return [client invokeHandler:name withArgs:args context:(HproseClientContext *)context];
        };
        defaultBeforeFilterHandler = ^id(NSData *request, HproseContext *context) {
            return [client beforeFilterHandler:request context:(HproseClientContext *)context];
        };
        defaultAfterFilterHandler = ^id(NSData *request, HproseContext *context) {
            return [client afterFilterHandler:request context:(HproseClientContext *)context];
        };
        invokeHandler = defaultInvokeHandler;
        beforeFilterHandler = defaultBeforeFilterHandler;
        afterFilterHandler = defaultAfterFilterHandler;
        _beforeFilter = [[HproseFilterHandlerManager alloc] init:@selector(addBeforeFilterHandler:) with:self];
        _afterFilter = [[HproseFilterHandlerManager alloc] init:@selector(addAfterFilterHandler:) with:self];
        autoId = nil;
        _clientId = nil;
        allTopics = [NSMutableDictionary dictionary];
        
    }
    return self;
}

- (id) init:(NSString *)aUri {
    if (self = [self init]) {
        [self setUri:aUri];
    }
    return self;
}

- (void) close:(BOOL)cancelPendingTasks {}

- (void) close {
    [self close: NO];
}

- (id) useService:(Protocol *)protocol {
    return [self useService:protocol withNameSpace:nil];
}

- (id) useService:(Protocol *)protocol withNameSpace:(NSString *)ns {
    return [[HproseClientProxy alloc] init:protocol withClient:self withNameSpace:ns];
}

- (id<HproseFilter>) getFilter {
    if ([filters count] == 0) {
        return nil;
    }
    return filters[0];
}

- (void) setFilter:(id<HproseFilter>)filter {
    if ([filters count] > 0) {
        [filters removeAllObjects];
    }
    if (filter != nil) {
        [filters addObject:filter];
    }
}

- (void) addFilter:(id<HproseFilter>)filter {
    [filters addObject:filter];
}

- (void) removeFilter:(id<HproseFilter>)filter {
    [filters removeObject:filter];
}

- (id) invoke:(NSString *)name {
    return [self invoke:name withArgs:nil settings:nil];
}

- (id) invoke:(NSString *)name settings:(id)settings {
    return [self invoke:name withArgs:nil settings:settings];
}

- (id) invoke:(NSString *)name withArgs:(NSArray *)args {
    return [self invoke:name withArgs:args settings:nil];
}

- (id) invoke:(NSString *)name withArgs:(NSArray *)args settings:(id)settings {
    HproseInvokeSettings *_settings;
    if (settings == nil) {
        _settings = [[HproseInvokeSettings alloc] init];
    }
    else if ([settings isKindOfClass:[HproseInvokeSettings class]]) {
        _settings = (HproseInvokeSettings *)settings;
    }
    else if ([settings isKindOfClass:[NSDictionary class]]) {
        _settings =[[HproseInvokeSettings alloc] init:(NSDictionary *)settings];
    }
    else {
        @throw [HproseException exceptionWithReason:@"settings must be a NSDictionary or HproseInvokeSettings object."];
    }
    if (_settings.delegate == nil) _settings.delegate = _delegate;
    if (_settings.delegate != nil) {
        if (_settings.selector == NULL) {
            _settings.selector = sel_registerName("callback");
            if (![_settings.delegate respondsToSelector:_settings.selector]) {
                _settings.selector = sel_registerName("callback:");
                if (![_settings.delegate respondsToSelector:_settings.selector]) {
                    _settings.selector = sel_registerName("callback:withArgs:");
                    if (![_settings.delegate respondsToSelector:_settings.selector]) {
                        _settings.selector = NULL;
                    }
                }
            }
        }
        if (_settings.errorSelector == NULL) {
            _settings.errorSelector = sel_registerName("errorHandler:withException:");
            if (![_settings.delegate respondsToSelector:_settings.selector]) {
                _settings.errorSelector = NULL;
            }
        }
    }
    if (_settings.selector != NULL || _settings.errorSelector != NULL ||
        _settings.callback != NULL || _settings.errorCallback != NULL ||
        _settings.block != nil || _settings.errorBlock != nil) {
        _settings.async = YES;
    }
    if ([_settings.resultClass isSubclassOfClass:[Promise class]]) {
        _settings.async = YES;
        _settings.resultClass = Nil;
    }
    if (_settings.resultType == 0) {
        _settings.resultType = _C_ID;
    }
    if (_settings.async) {
        return [self asyncInvoke:name withArgs:args settings:_settings];
    }
    else {
        return [self syncInvoke:name withArgs:args settings:_settings];
    }
}

HproseNextInvokeHandler getNextInvokeHandler(HproseNextInvokeHandler next, HproseInvokeHandler handler) {
    return ^id(NSString *name, NSArray *args, HproseContext *context) {
        return handler(name, args, context, next);
    };
}

- (void) addInvokeHandler:(HproseInvokeHandler)handler {
    if (handler == nil) return;
    [invokeHandlers addObject:handler];
    HproseNextInvokeHandler next = defaultInvokeHandler;
    for (NSUInteger i = invokeHandlers.count; i > 0; --i) {
        next = getNextInvokeHandler(next, invokeHandlers[i - 1]);
    }
    invokeHandler = next;
}

HproseNextFilterHandler getNextFilterHandler(HproseNextFilterHandler next, HproseFilterHandler handler) {
    return ^id(NSData *request, HproseContext *context) {
        return handler(request, context, next);
    };
}

- (void) addBeforeFilterHandler:(HproseFilterHandler)handler {
    if (handler == nil) return;
    [beforeFilterHandlers addObject:handler];
    HproseNextFilterHandler next = defaultBeforeFilterHandler;
    for (NSUInteger i = beforeFilterHandlers.count; i > 0; --i) {
        next = getNextFilterHandler(next, beforeFilterHandlers[i - 1]);
    }
    beforeFilterHandler = next;
}

- (void) addAfterFilterHandler:(HproseFilterHandler)handler {
    if (handler == nil) return;
    [afterFilterHandlers addObject:handler];
    HproseNextFilterHandler next = defaultAfterFilterHandler;
    for (NSUInteger i = afterFilterHandlers.count; i > 0; --i) {
        next = getNextFilterHandler(next, afterFilterHandlers[i - 1]);
    }
    afterFilterHandler = next;
}

- (HproseClient *) use:(HproseInvokeHandler)handler {
    [self addInvokeHandler:handler];
    return self;
}

- (void) subscribe:(NSString *)name callback:(void (^)(id))callback {
    [self subscribe:name callback:callback resultType:_C_ID resultClass:Nil timeout:self.timeout];
}

- (void) subscribe:(NSString *)name callback:(void (^)(id))callback timeout:(NSTimeInterval)timeout {
    [self subscribe:name callback:callback resultType:_C_ID resultClass:Nil timeout:timeout];
}

- (void) subscribe:(NSString *)name callback:(void (^)(id))callback resultType:(char)resultType {
    [self subscribe:name callback:callback resultType:resultType resultClass:Nil timeout:self.timeout];
}

- (void) subscribe:(NSString *)name callback:(void (^)(id))callback resultType:(char)resultType timeout:(NSTimeInterval)timeout {
    [self subscribe:name callback:callback resultType:resultType resultClass:Nil timeout:timeout];
}

- (void) subscribe:(NSString *)name callback:(void (^)(id))callback resultClass:(Class)resultClass {
    [self subscribe:name callback:callback resultType:_C_ID resultClass:resultClass timeout:self.timeout];
}

- (void) subscribe:(NSString *)name callback:(void (^)(id))callback resultClass:(Class)resultClass timeout:(NSTimeInterval)timeout {
    [self subscribe:name callback:callback resultType:_C_ID resultClass:resultClass timeout:timeout];
}

- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback {
    [self subscribe:name id:clientId callback:callback resultType:_C_ID resultClass:Nil timeout:self.timeout];
}

- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback timeout:(NSTimeInterval)timeout {
    [self subscribe:name id:clientId callback:callback resultType:_C_ID resultClass:Nil timeout:timeout];
}

- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback resultType:(char)resultType {
    [self subscribe:name id:clientId callback:callback resultType:resultType resultClass:Nil timeout:self.timeout];
}

- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback resultType:(char)resultType timeout:(NSTimeInterval)timeout {
    [self subscribe:name id:clientId callback:callback resultType:resultType resultClass:Nil timeout:timeout];
}

- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback resultClass:(Class)resultClass {
    [self subscribe:name id:clientId callback:callback resultType:_C_ID resultClass:resultClass timeout:self.timeout];
}

- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback resultClass:(Class)resultClass timeout:(NSTimeInterval)timeout {
    [self subscribe:name id:clientId callback:callback resultType:_C_ID resultClass:resultClass timeout:timeout];
}

void delTopic(NSMutableDictionary *topics, NSNumber *clientId, void (^callback)(id)) {
    if (topics != nil && topics.count > 0) {
        if (callback != nil) {
            HproseTopic *topic = topics[clientId];
            if (topic != nil) {
                [topic.callbacks removeObject:callback];
                if (topic.callbacks.count == 0) {
                    [topics removeObjectForKey:clientId];
                }
            }
        }
        else {
            [topics removeObjectForKey:clientId];
        }
    }
}

- (void) unsubscribe:(NSString *)name {
    [self unsubscribe:name callback:nil];
}

- (void) unsubscribe:(NSString *)name id:(int32_t)clientId {
    [self unsubscribe:name id:clientId callback:nil];
}

- (void) unsubscribe:(NSString *)name callback:(void (^)(id))callback {
    NSMutableDictionary<NSNumber *, HproseTopic *> *topics = allTopics[name];
    if (topics != nil) {
        if (autoId == nil) {
            for (NSNumber *i in topics) {
                delTopic(topics, i, callback);
            }
        }
        else {
            [autoId last:^(NSNumber *clientId) {
                delTopic(topics, clientId, callback);
            }];
        }
    }
}

- (void) unsubscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback {
    NSMutableDictionary<NSNumber *, HproseTopic *> *topics = allTopics[name];
    if (topics != nil) {
        delTopic(topics, @(clientId), callback);
    }
}

@end

@implementation HproseClient(PrivateMethods)

- (id) syncInvoke:(NSString *)name withArgs:(NSArray *)args settings:(HproseInvokeSettings *)settings {
    HproseClientContext *context = [[HproseClientContext alloc] init:self settings:settings];
    return invokeHandler(name, args, context);
}

- (id) asyncInvoke:(NSString *)name withArgs:(NSArray *)args settings:(HproseInvokeSettings *)settings {
    Promise *promise = [Promise promise];
    if (settings.delegate != nil && settings.selector != NULL) {
        NSMethodSignature *methodSignature = [settings.delegate methodSignatureForSelector:settings.selector];
        if (methodSignature == nil) {
            HproseException *exception = [HproseException exceptionWithReason:
                                          [NSString stringWithFormat:
                                           @"Not support this callback: %@, the delegate doesn't respond to the selector.",
                                           NSStringFromSelector(settings.selector)]];
            [self errorHandler:name
                 withException:exception
                      settings:settings];
            [promise reject:exception];
            return promise;
        }
        NSUInteger n = [methodSignature numberOfArguments];
        if (n < 2 || n > 4) {
            HproseException *exception = [HproseException exceptionWithReason:
                                          [NSString stringWithFormat:
                                           @"Not support this callback: %@, number of arguments is wrong.",
                                           NSStringFromSelector(settings.selector)]];
            [self errorHandler:name
                 withException:exception
                      settings:settings];
            [promise reject:exception];
            return promise;
        }
        if (n > 2) {
            const char *types = [methodSignature getArgumentTypeAtIndex:2];
            if (types != NULL && [HproseHelper isSerializableType:types[0]]) {
                if (types[0] == _C_ID) {
                    if (strlen(types) > 3) {
                        NSString *className = [@(types)
                                               substringWithRange:
                                               NSMakeRange(2, strlen(types) - 3)];
                        settings.resultClass = objc_getClass([className UTF8String]);
                    }
                }
                settings.resultType = types[0];
            }
            else {
                HproseException *exception =[HproseException exceptionWithReason:
                                             [NSString stringWithFormat:@"Not support this type: %s", types]];
                [self errorHandler:name
                     withException:exception
                          settings:settings];
                [promise reject:exception];
                return promise;
            }
        }
    }
    HproseClientContext *context = [[HproseClientContext alloc] init:self settings:settings];
    @try {
        if (settings.byref && ![args isKindOfClass:[NSMutableArray class]]) {
            args = [args mutableCopy];
        }
        id result = invokeHandler(name, args, context);
        if ([Promise isPromise:result]) {
            [(Promise *)result last:^(id result) {
                [promise resolve:result];
                if (settings.callback) {
                    settings.callback(result, args);
                }
                else if (settings.block) {
                    settings.block(result, args);
                }
                else if (settings.delegate != nil && settings.selector != NULL) {
                    id delegate = settings.delegate;
                    SEL selector = settings.selector;
                    NSMethodSignature *methodSignature = [delegate methodSignatureForSelector:selector];
                    NSUInteger n = [methodSignature numberOfArguments];
                    switch (n) {
                        case 2: ((void (*)(id, SEL))objc_msgSend)(delegate, selector); break;
                        case 3: {
                            switch (settings.resultType) {
                                case _C_ID: ((void (*)(id, SEL, id))objc_msgSend)(delegate, selector, result); break;
                                case _C_CHR: ((void (*)(id, SEL, char))objc_msgSend)(delegate, selector, [result charValue]); break;
                                case _C_UCHR: ((void (*)(id, SEL, unsigned char))objc_msgSend)(delegate, selector, [result unsignedCharValue]); break;
                                case _C_SHT: ((void (*)(id, SEL, short))objc_msgSend)(delegate, selector, [result shortValue]); break;
                                case _C_USHT: ((void (*)(id, SEL, unsigned short))objc_msgSend)(delegate, selector, [result unsignedShortValue]); break;
                                case _C_INT: ((void (*)(id, SEL, int))objc_msgSend)(delegate, selector, [result intValue]); break;
                                case _C_UINT: ((void (*)(id, SEL, unsigned int))objc_msgSend)(delegate, selector, [result unsignedIntValue]); break;
                                case _C_LNG: ((void (*)(id, SEL, long))objc_msgSend)(delegate, selector, [result longValue]); break;
                                case _C_ULNG: ((void (*)(id, SEL, unsigned long))objc_msgSend)(delegate, selector, [result unsignedLongValue]); break;
                                case _C_LNG_LNG: ((void (*)(id, SEL, long long))objc_msgSend)(delegate, selector, [result longLongValue]); break;
                                case _C_ULNG_LNG: ((void (*)(id, SEL, unsigned long long))objc_msgSend)(delegate, selector, [result unsignedLongLongValue]); break;
                                case _C_FLT: ((void (*)(id, SEL, float))objc_msgSend)(delegate, selector, [result floatValue]); break;
                                case _C_DBL: ((void (*)(id, SEL, double))objc_msgSend)(delegate, selector, [result doubleValue]); break;
                                case _C_BOOL: ((void (*)(id, SEL, BOOL))objc_msgSend)(delegate, selector, [result boolValue]); break;
                                case _C_CHARPTR: ((void (*)(id, SEL, const char *))objc_msgSend)(delegate, selector, [result UTF8String]); break;
                            }
                            break;
                        }
                        case 4: {
                            switch (settings.resultType) {
                                case _C_ID: ((void (*)(id, SEL, id, NSArray *))objc_msgSend)(delegate, selector, result, args); break;
                                case _C_CHR: ((void (*)(id, SEL, char, NSArray *))objc_msgSend)(delegate, selector, [result charValue], args); break;
                                case _C_UCHR: ((void (*)(id, SEL, unsigned char, NSArray *))objc_msgSend)(delegate, selector, [result unsignedCharValue], args); break;
                                case _C_SHT: ((void (*)(id, SEL, short, NSArray *))objc_msgSend)(delegate, selector, [result shortValue], args); break;
                                case _C_USHT: ((void (*)(id, SEL, unsigned short, NSArray *))objc_msgSend)(delegate, selector, [result unsignedShortValue], args); break;
                                case _C_INT: ((void (*)(id, SEL, int, NSArray *))objc_msgSend)(delegate, selector, [result intValue], args); break;
                                case _C_UINT: ((void (*)(id, SEL, unsigned int, NSArray *))objc_msgSend)(delegate, selector, [result unsignedIntValue], args); break;
                                case _C_LNG: ((void (*)(id, SEL, long, NSArray *))objc_msgSend)(delegate, selector, [result longValue], args); break;
                                case _C_ULNG: ((void (*)(id, SEL, unsigned long, NSArray *))objc_msgSend)(delegate, selector, [result unsignedLongValue], args); break;
                                case _C_LNG_LNG: ((void (*)(id, SEL, long long, NSArray *))objc_msgSend)(delegate, selector, [result longLongValue], args); break;
                                case _C_ULNG_LNG: ((void (*)(id, SEL, unsigned long long, NSArray *))objc_msgSend)(delegate, selector, [result unsignedLongLongValue], args); break;
                                case _C_FLT: ((void (*)(id, SEL, float, NSArray *))objc_msgSend)(delegate, selector, [result floatValue], args); break;
                                case _C_DBL: ((void (*)(id, SEL, double, NSArray *))objc_msgSend)(delegate, selector, [result doubleValue], args); break;
                                case _C_BOOL: ((void (*)(id, SEL, BOOL, NSArray *))objc_msgSend)(delegate, selector, [result boolValue], args); break;
                                case _C_CHARPTR: ((void (*)(id, SEL, const char *, NSArray *))objc_msgSend)(delegate, selector, [result UTF8String], args); break;
                            }
                            break;
                        }
                    }
                }
            } catch:^(id e) {
                [self errorHandler:name withException:e settings:settings];
                [promise reject:e];
            }];
        }
    }
    @catch (NSException *e) {
        [self errorHandler:name withException:e settings:settings];
        [promise reject:e];
    }
    return promise;
}

- (oneway void) errorHandler:(NSString *)name withException:(NSException *)e settings:(HproseInvokeSettings *)settings {
    if (settings.errorCallback) {
        settings.errorCallback(name, e);
    }
    else if (settings.errorBlock) {
        settings.errorBlock(name, e);
    }
    else if (settings.delegate != nil && settings.errorSelector != NULL && [settings.delegate respondsToSelector:settings.errorSelector]) {
        ((void (*)(id, SEL, NSString *, NSException *))objc_msgSend)(settings.delegate, settings.errorSelector, name, e);
    }
    else if (_errorCallback) {
        _errorCallback(name, e);
    }
    else if (_errorHandler) {
        _errorHandler(name, e);
    }
    else if (_delegate != nil && _onError != NULL && [_delegate respondsToSelector:_onError]) {
        ((void (*)(id, SEL, NSString *, NSException *))objc_msgSend)(_delegate, _onError, name, e);
    }
}

- (NSData *) outputFilter:(NSData *)request context:(HproseClientContext *)context {
    for (NSUInteger i = 0, n = filters.count; i < n; ++i) {
        request = [filters[i] outputFilter:request withContext:context];
    }
    return request;
}

- (NSData *) inputFilter:(NSData *)response context:(HproseClientContext *)context {
    for (NSUInteger i = filters.count; i > 0; --i) {
        response = [filters[i - 1] inputFilter:response withContext:context];
    }
    return response;
}

- (id) beforeFilterHandler:(NSData *)request context:(HproseClientContext *)context {
    request = [self outputFilter:request context:context];
    id response = afterFilterHandler(request, context);
    if ([Promise isPromise:response]) {
        return [((Promise *)response) then:^id(NSData *response) {
            if (context.settings.oneway) return nil;
            response = [self inputFilter:response context:context];
            return response;
        }];
    }
    else if ([response isKindOfClass:[NSData class]]) {
        if (context.settings.oneway) return nil;
        response = [self inputFilter:(NSData *)response context:context];
        return response;
    }
    else {
        @throw [HproseException exceptionWithReason:@"Wrong return type of afterFilterHander"];
    }
}

- (id) afterFilterHandler:(NSData *)request context:(HproseClientContext *)context {
    if (context.settings.async) {
        Promise *response = [Promise promise];
        [self sendAsync:request timeout:context.settings.timeout receiveAsync:^(NSData *data) {
            [response resolve:data];
        } error:^(NSException *e) {
            [response reject:e];
        }];
        return response;
    }
    return [self sendAndReceive:request timeout:context.settings.timeout];
}

- (id) sendAndReceive:(NSData *)request context:(HproseClientContext *)context {
    @try {
        id response = beforeFilterHandler(request, context);
        if ([Promise isPromise:response]) {
            return [((Promise *) response) catch:^id(id e) {
                id response = [self retry:request context:context];
                if (response != nil) {
                    return response;
                }
                @throw e;
            }];
        }
        else if ([response isKindOfClass:[NSData class]]) {
            return response;
        }
        else {
            @throw [HproseException exceptionWithReason:@"Wrong return type of beforeFilterHander"];
        }
    }
    @catch (NSException *e) {
        id response = [self retry:request context:context];
        if (response != nil) {
            return response;
        }
        @throw e;
    }
}

- (id) retry:(NSData *)request context:(HproseClientContext *)context {
    HproseInvokeSettings *settings = context.settings;
    if (settings.failswitch) {
        int64_t i = OSAtomicAdd64(1, &index);
        if (i >= uris.count) {
            index = 0;
            i = index;
        }
        _uri = uris[i];
    }
    if (settings.idempotent) {
        NSUInteger n = settings.retry;
        if (n > 0) {
            settings.retry = n - 1;
            NSTimeInterval interval = (n >= 10) ? 0.5 : (10 - n) * 0.5;
            if (settings.async) {
                return [Promise delayed:interval block:^id{
                    return [self sendAndReceive:request context:context];
                }];
            }
            else {
                [NSThread sleepForTimeInterval:interval];
                return [self sendAndReceive:request context:context];
            }
        }
    }
    return nil;
}

NSData * encode(NSString *name, NSArray *args, HproseClientContext *context) {
    HproseInvokeSettings *settings = context.settings;
    NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
    [stream open];
    @try {
        HproseWriter *writer = [HproseWriter writerWithStream:stream simple:settings.simple];
        [stream writeByte:HproseTagCall];
        [writer writeString:name];
        if (args != nil && (args.count > 0 || settings.byref)) {
            [writer reset];
            [writer writeArray:args];
            if (settings.byref) {
                [writer writeBoolean:YES];
            }
        }
        [stream writeByte:HproseTagEnd];
        NSData *data = [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        return data;
    }
    @finally {
        [stream close];
    }
}

HproseException * wrongResponse(NSData *data) {
    return [HproseException exceptionWithReason:[NSString stringWithFormat:@"Wrong Response: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
}

id decode(NSData *data, NSArray *args, HproseClientContext *context) {
    HproseInvokeSettings *settings = context.settings;
    if (settings.oneway) {
        return nil;
    }
    if (data.length == 0) {
        @throw [HproseException exceptionWithReason:@"EOF"];
    }
    int tag = ((uint8_t *)data.bytes)[data.length - 1];
    if (tag != HproseTagEnd) {
        @throw wrongResponse(data);
    }
    HproseResultMode mode = settings.mode;
    if (mode == HproseResultMode_RawWithEndTag) {
        return data;
    }
    if (mode == HproseResultMode_Raw) {
        return [NSData dataWithBytes:data.bytes length:data.length - 1];
    }
    id result = nil;
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    [stream open];
    @try {
        HproseReader *reader = [HproseReader readerWithStream:stream];
        tag = [stream readByte];
        if (tag == HproseTagResult) {
            if (mode == HproseResultMode_Normal) {
                result = [reader unserialize:settings.resultClass withType:settings.resultType];
            }
            else {
                result = [reader readRaw];
            }
            tag = [stream readByte];
            if (tag == HproseTagArgument) {
                [reader reset];
                NSArray *arguments = [reader readArray];
                if (args != nil) {
                    NSUInteger n = arguments.count;
                    if (n > args.count) {
                        n = args.count;
                    }
                    if ([args isKindOfClass:[NSMutableArray class]]) {
                        NSMutableArray *_args = (NSMutableArray *)args;
                        for (NSUInteger i = 0; i < n; i++) {
                            _args[i] = arguments[i];
                        }
                    }
                }
                tag = [stream readByte];
            }
        }
        else if (tag == HproseTagError) {
            @throw [HproseException exceptionWithReason:[reader readString]];
        }
        if (tag != HproseTagEnd) {
            @throw wrongResponse(data);
        }
    }
    @finally {
        [stream close];
    }
    return result;
}

- (id) invokeHandler:(NSString *)name withArgs:(NSArray *)args context:(HproseClientContext *)context {
    NSData *request = encode(name, args, context);
    id response = [self sendAndReceive:request context:context];
    if ([Promise isPromise:response]) {
        return [(Promise *)response then:^id(NSData *response) {
            return decode((NSData *)response, args, context);
        }];
    }
    else {
        return decode((NSData *)response, args, context);
    }
}

- (Promise *) getAutoId {
    if (autoId == nil) {
        autoId = (Promise *)[self invoke:@"#" settings:autoIdSettings];
        [autoId last:^(NSNumber *value) {
            _clientId = value;
        }];
    }
    return autoId;
}

- (HproseTopic *) getTopic:(NSString *)name id:(int32_t)id create:(BOOL)create {
    NSMutableDictionary<NSNumber *, HproseTopic *> *topics = allTopics[name];
    if (topics != nil) {
        return topics[@(id)];
    }
    if (create) {
        allTopics[name] = [NSMutableDictionary dictionary];
    }
    return nil;
}

- (void) subscribe:(NSString *)name callback:(void (^)(id))callback resultType:(char)resultType resultClass:(Class)resultClass timeout:(NSTimeInterval)timeout {
    [[self getAutoId] last:^(NSNumber *clientId) {
        [self subscribe:name id:[clientId intValue] callback:callback resultType:resultType resultClass:resultClass timeout:timeout];
    }];
}

- (void) subscribe:(NSString *)name id:(int32_t)clientId callback:(void (^)(id))callback resultType:(char)resultType resultClass:(Class)resultClass timeout:(NSTimeInterval)timeout {
    HproseTopic *topic = [self getTopic:name id:clientId create:YES];
    if (topic == nil) {
        void (^cb)(NSException *) = ^(NSException *e) {
            HproseTopic *topic = [self getTopic:name id:clientId create:NO];
            if (topic != nil) {
                HproseInvokeSettings *settings = [[HproseInvokeSettings alloc] init];
                settings.idempotent = YES;
                settings.failswitch = NO;
                settings.resultType = resultType;
                settings.resultClass = resultClass;
                settings.timeout = timeout;
                settings.async = YES;
                @try {
                    Promise *result = [self invoke:name withArgs:@[@(clientId)] settings:settings];
                    [result last:topic.handler catch:cb];
                }
                @catch (NSException *e) {
                    cb(e);
                }
            }
        };
        topic = [[HproseTopic alloc] init];
        topic.handler = ^(id result) {
            HproseTopic *topic = [self getTopic:name id:clientId create:NO];
            if (topic != nil) {
                if (result != nil) {
                    for (void (^callback)(id) in topic.callbacks) {
                        @try {
                            callback(result);
                        }
                        @catch (id e) {}
                    }
                }
                cb(nil);
            }
        };
        [topic.callbacks addObject:callback];
        allTopics[name][@(clientId)] = topic;
        @try {
            cb(nil);
        }
        @catch (NSException *exception) {
            [self errorHandler:name withException:exception settings:[[HproseInvokeSettings alloc] init]];
        }
    }
    else if (![topic.callbacks containsObject:callback]) {
        [topic.callbacks addObject:callback];
    }
}

@end
