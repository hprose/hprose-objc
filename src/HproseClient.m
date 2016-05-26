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
 * LastModified: May 26, 2016                             *
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
#import "Promise.h"

@implementation HproseClientContext

- (id) init:(HproseClient *)client settings:(HproseInvokeSettings *)settings {
    if (self = [super init]) {
        _client = client;
        _settings = settings;
    }
    return self;
}

@end

@interface HproseClient(PrivateMethods)

- (id) syncInvoke:(NSString *)name withArgs:(NSArray *)args settings:(HproseInvokeSettings *)settings;
- (id) asyncInvoke:(NSString *)name withArgs:(NSArray *)args settings:(HproseInvokeSettings *)settings;
- (oneway void) errorHandler:(NSString *)name withException:(NSException *)e settings:(HproseInvokeSettings *)settings;
- (HproseException *) wrongResponse:(NSData *)data;
- (NSData *) doOutput:(NSString *)name withArgs:(NSArray *)args context:(HproseClientContext *)context;
- (id) doInput:(NSData *)data withArgs:(NSArray *)args context:(HproseClientContext *)context;

@end

@implementation HproseClient

+ (id) client {
    return [[self alloc] init];
}

+ (id) client:(NSString *)aUri {
    return [[self alloc] init:aUri];
}

- (id) init {
    if (self = [super init]) {
        filters = [NSMutableArray array];
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
    if ([settings isKindOfClass:[HproseInvokeSettings class]]) {
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

@end

@implementation HproseClient(PrivateMethods)

- (id) syncInvoke:(NSString *)name withArgs:(NSArray *)args settings:(HproseInvokeSettings *)settings {
    HproseClientContext *context = [[HproseClientContext alloc] init:self settings:settings];
    NSData * data = [self doOutput:name withArgs:args context:context];
    data = [self sendAndReceive:data];
    id result = [self doInput:data withArgs:args context:context];
    if ([result isKindOfClass:[NSException class]]) {
        @throw result;
    }
    return result;
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
        NSData *data = [self doOutput:name withArgs:args context:context];
        [self sendAsync:data receiveAsync:^(NSData *data) {
            @try {
                NSArray *_args = args;
                if (settings.byref && ![args isKindOfClass:[NSMutableArray class]]) {
                    _args = [args mutableCopy];
                }
                id result = [self doInput:data withArgs:_args context:context];
                if ([result isMemberOfClass:[HproseException class]]) {
                    [self errorHandler:name withException:result settings:settings];
                    [promise reject:result];
                }
                else {
                    [promise resolve:result];
                    if (settings.callback) {
                        settings.callback(result, _args);
                    }
                    else if (settings.block) {
                        settings.block(result, _args);
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
                                    case _C_ID: ((void (*)(id, SEL, id, NSArray *))objc_msgSend)(delegate, selector, result, _args); break;
                                    case _C_CHR: ((void (*)(id, SEL, char, NSArray *))objc_msgSend)(delegate, selector, [result charValue], _args); break;
                                    case _C_UCHR: ((void (*)(id, SEL, unsigned char, NSArray *))objc_msgSend)(delegate, selector, [result unsignedCharValue], _args); break;
                                    case _C_SHT: ((void (*)(id, SEL, short, NSArray *))objc_msgSend)(delegate, selector, [result shortValue], _args); break;
                                    case _C_USHT: ((void (*)(id, SEL, unsigned short, NSArray *))objc_msgSend)(delegate, selector, [result unsignedShortValue], _args); break;
                                    case _C_INT: ((void (*)(id, SEL, int, NSArray *))objc_msgSend)(delegate, selector, [result intValue], _args); break;
                                    case _C_UINT: ((void (*)(id, SEL, unsigned int, NSArray *))objc_msgSend)(delegate, selector, [result unsignedIntValue], _args); break;
                                    case _C_LNG: ((void (*)(id, SEL, long, NSArray *))objc_msgSend)(delegate, selector, [result longValue], _args); break;
                                    case _C_ULNG: ((void (*)(id, SEL, unsigned long, NSArray *))objc_msgSend)(delegate, selector, [result unsignedLongValue], _args); break;
                                    case _C_LNG_LNG: ((void (*)(id, SEL, long long, NSArray *))objc_msgSend)(delegate, selector, [result longLongValue], _args); break;
                                    case _C_ULNG_LNG: ((void (*)(id, SEL, unsigned long long, NSArray *))objc_msgSend)(delegate, selector, [result unsignedLongLongValue], _args); break;
                                    case _C_FLT: ((void (*)(id, SEL, float, NSArray *))objc_msgSend)(delegate, selector, [result floatValue], _args); break;
                                    case _C_DBL: ((void (*)(id, SEL, double, NSArray *))objc_msgSend)(delegate, selector, [result doubleValue], _args); break;
                                    case _C_BOOL: ((void (*)(id, SEL, BOOL, NSArray *))objc_msgSend)(delegate, selector, [result boolValue], _args); break;
                                    case _C_CHARPTR: ((void (*)(id, SEL, const char *, NSArray *))objc_msgSend)(delegate, selector, [result UTF8String], _args); break;
                                }
                                break;
                            }
                        }
                    }
                }
            }
            @catch (NSException *e) {
                [self errorHandler:name withException:e settings:settings];
                [promise reject:e];
            }
        } error:^(NSException *e) {
            [self errorHandler:name withException:e settings:settings];
            [promise reject:e];
        }];
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
    else {
        NSLog(@"%@", e);
    }
}

- (HproseException *) wrongResponse:(NSData *)data {
    return [HproseException exceptionWithReason:[NSString stringWithFormat:@"Wrong Response: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
}

- (NSData *) doOutput:(NSString *)name withArgs:(NSArray *)args context:(HproseClientContext *)context {
    HproseInvokeSettings *settings = context.settings;
    NSOutputStream *ostream = [NSOutputStream outputStreamToMemory];
    [ostream open];
    @try {
        HproseWriter *writer = [HproseWriter writerWithStream:ostream simple:settings.simple];
        [ostream writeByte:HproseTagCall];
        [writer writeString:name];
        if (args != nil && ([args count] > 0 || settings.byref)) {
            [writer reset];
            [writer writeArray:args];
            if (settings.byref) {
                [writer writeBoolean:YES];
            }
        }
        [ostream writeByte:HproseTagEnd];
        NSData *data = [ostream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        for (NSUInteger i = 0, n = filters.count; i < n; ++i) {
            data = [filters[i] outputFilter:data withContext:context];
        }
        return data;
    }
    @finally {
        [ostream close];
    }
}

- (id) doInput:(NSData *)data withArgs:(NSArray *)args context:(HproseClientContext *)context {
    if ([data length] == 0) {
        @throw [HproseException exceptionWithReason:@"EOF"];
    }
    for (int i = (int)filters.count - 1; i >= 0; --i) {
        data = [filters[i] inputFilter:data withContext:context];
    }
    int tag = ((uint8_t *)[data bytes])[[data length] - 1];
    if (tag != HproseTagEnd) {
        @throw [self wrongResponse:data];
    }
    HproseInvokeSettings *settings = context.settings;
    HproseResultMode mode = settings.mode;
    if (mode == HproseResultMode_Raw) {
        data = [NSData dataWithBytes:[data bytes] length:[data length] - 1];
    }
    if (mode == HproseResultMode_RawWithEndTag || mode == HproseResultMode_Raw) {
        return data;
    }
    id result = nil;
    NSInputStream *istream = [NSInputStream inputStreamWithData:data];
    [istream open];
    @try {
        HproseReader *reader = [HproseReader readerWithStream:istream];
        while ((tag = [istream readByte]) != HproseTagEnd) {
            switch (tag) {
                case HproseTagResult: {
                    if (mode == HproseResultMode_Normal) {
                        [reader reset];
                        result = [reader unserialize:settings.resultClass withType:settings.resultType];
                    }
                    else {
                        result = [reader readRaw];
                    }
                    break;
                }
                case HproseTagArgument: {
                    [reader reset];
                    NSArray *arguments = [reader readArray];
                    if (args != nil) {
                        NSUInteger n = [arguments count];
                        if (n > [args count]) {
                            n = [args count];
                        }
                        if ([args isKindOfClass:[NSMutableArray class]]) {
                            NSMutableArray *_args = (NSMutableArray *)args;
                            for (NSUInteger i = 0; i < n; i++) {
                                _args[i] = arguments[i];
                            }
                        }
                    }
                    break;
                }
                case HproseTagError: {
                    [reader reset];
                    result = [HproseException exceptionWithReason:[reader readString]];
                    break;
                }
                default: {
                    @throw [self wrongResponse:data];
                }
            }
        }
    }
    @finally {
        [istream close];
    }
    return result;
}

@end
