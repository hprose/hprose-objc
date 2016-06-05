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
 * HproseInvokeSettings.m                                 *
 *                                                        *
 * hprose invoke settings for Objective-C.                *
 *                                                        *
 * LastModified: Jun 5, 2016                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import "HproseInvokeSettings.h"

@implementation HproseInvokeSettings

- (id) init {
    if (self = [super init]) {
        _mode = HproseResultMode_Normal;
        _async = NO;
        _byref = nil;
        _simple = nil;
        _idempotent = nil;
        _failswitch = nil;
        _oneway = nil;
        _retry = nil;
        _timeout = nil;
        _resultType = 0;
        _resultClass = Nil;
        _block = nil;
        _errorBlock = nil;
        _callback = NULL;
        _errorCallback = NULL;
        _selector = NULL;
        _errorSelector = NULL;
    }
    return self;
}

- (id) init:(NSDictionary *)settings {
    if (self = [self init]) {
        if (settings[@"mode"] != nil) {
            self.mode = (HproseResultMode)[settings[@"mode"] intValue];
        }
        if (settings[@"async"] != nil) {
            self.async = [settings[@"async"] boolValue];
        }
        if (settings[@"byref"] != nil) {
            self.byref = [settings[@"byref"] boolValue];
        }
        if (settings[@"simple"] != nil) {
            self.simple = [settings[@"simple"] boolValue];
        }
        if (settings[@"idempotent"] != nil) {
            self.idempotent = [settings[@"idempotent"] boolValue];
        }
        if (settings[@"failswitch"] != nil) {
            self.failswitch = [settings[@"failswitch"] boolValue];
        }
        if (settings[@"oneway"] != nil) {
            self.oneway = [settings[@"oneway"] boolValue];
        }
        if (settings[@"retry"] != nil) {
            self.retry = [settings[@"retry"] unsignedIntegerValue];
        }
        if (settings[@"timeout"] != nil) {
            self.timeout = [settings[@"timeout"] doubleValue];
        }
        if (settings[@"resultType"] != nil) {
            self.resultType = [settings[@"resultType"] charValue];
        }
        if (settings[@"resultClass"] != nil) {
            self.resultClass = (Class)settings[@"resultClass"];
        }
        if (settings[@"delegate"] != nil) {
            self.delegate = settings[@"delegate"];
        }
        if (settings[@"block"] != nil) {
            self.block = (HproseBlock)settings[@"block"];
        }
        if (settings[@"errorBlock"] != nil) {
            self.errorBlock = (HproseErrorBlock)settings[@"errorBlock"];
        }
        if (settings[@"callback"] != nil) {
            [(NSValue *)settings[@"callback"] getValue:&_callback];
        }
        if (settings[@"errorCallback"] != nil) {
            [(NSValue *)settings[@"errorCallback"] getValue:&_errorCallback];
        }
        if (settings[@"selector"] != nil) {
            [(NSValue *)settings[@"selector"] getValue:&_selector];
        }
        if (settings[@"errorSelector"] != nil) {
            [(NSValue *)settings[@"errorSelector"] getValue:&_errorSelector];
        }
    }
    return self;
}

+ (HproseInvokeSettings *) settings:(NSDictionary *)settings {
    return [[self alloc] init:settings];
}

- (void) setByref:(BOOL)value {
    _byref = @(value);
}

- (BOOL) getByref {
    return [_byref boolValue];
}

- (void) setSimple:(BOOL)value {
    _simple = @(value);
}

- (BOOL) getSimple {
    return [_simple boolValue];
}

- (void) setIdempotent:(BOOL)value {
    _idempotent = @(value);
}

- (BOOL) getIdempotent {
    return [_idempotent boolValue];
}

- (void) setFailswitch:(BOOL)value {
    _failswitch = @(value);
}

- (BOOL) getFailswitch {
    return [_failswitch boolValue];
}

- (void) setOneway:(BOOL)value {
    _oneway = @(value);
}

- (BOOL) getOneway {
    return [_oneway boolValue];
}

- (void) setRetry:(NSUInteger)value {
    _retry = @(value);
}

- (NSUInteger) getRetry {
    return [_retry unsignedIntegerValue];
}

- (void) setTimeout:(NSTimeInterval)value {
    _timeout = @(value);
}

- (NSTimeInterval) getTimeout {
    return [_timeout doubleValue];
}

- (void) copyTo:(HproseInvokeSettings *)settings {
    settings.mode = self.mode;
    settings.async = self.async;
    if (_byref != nil) settings.byref = self.byref;
    if (_simple != nil) settings.simple = self.simple;
    if (_idempotent != nil) settings.idempotent = self.idempotent;
    if (_failswitch != nil) settings.failswitch = self.failswitch;
    if (_oneway != nil) settings.oneway = self.oneway;
    if (_retry != nil) settings.retry = self.retry;
    if (_timeout != nil) settings.timeout = self.timeout;
    if (_resultType != 0) settings.resultType = self.resultType;
    if (_resultClass != Nil) settings.resultClass = self.resultClass;
    if (_block != nil) settings.block = self.block;
    if (_errorBlock != nil) settings.errorBlock = self.errorBlock;
    if (_callback != NULL) settings.callback = self.callback;
    if (_errorCallback != NULL) settings.errorCallback = self.errorCallback;
    if (_selector != NULL) settings.selector = self.selector;
    if (_errorSelector != NULL) settings.errorSelector = self.errorSelector;
    if (_delegate != nil) settings.delegate = self.delegate;
}

@end