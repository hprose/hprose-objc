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
 * LastModified: Apr 11, 2014                             *
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

@implementation HproseExceptionHandler

- (oneway void) doErrorCallback:(NSException *)e {
    id delegate = [_client delegate];
    SEL onError = [_client onError];
    HproseErrorEvent errorHandler = [_client errorHandler];
    if ([delegate respondsToSelector:onError]) {
        ((void (*)(id, SEL,NSString *,NSException *))objc_msgSend)(delegate, onError, _name, e);
    }
    else if (errorHandler) {
        errorHandler(_name, e);
    }
    else if ([_delegate respondsToSelector:onError]) {
        ((void (*)(id, SEL,NSString *,NSException *))objc_msgSend)(_delegate, onError, _name, e);
    }
    else {
        NSLog(@"%@", e);
    }
}

@end

@interface HproseClient(PrivateMethods)

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block;
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback block:(HproseBlock)block delegate:(id)delegate selector:(SEL)selector;

- (HproseException *) wrongResponse:(NSData *)data;
- (NSData *) doOutput:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple;
- (id) doInput:(NSData *)data withArgs:(NSMutableArray *)args resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode;

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
        filters = [NSMutableArray new];
    }
    return self;

}

- (id) init:(NSString *)aUri {
    if (self = [self init]) {
        [self setUri:aUri];
    }
    return self;
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
    return [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:YES];
}
- (id) invoke:(NSString *)name resultType:(char)type {
    return [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:YES];
}
- (id) invoke:(NSString *)name resultClass:(Class)cls {
    return [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:YES];
}
- (id) invoke:(NSString *)name resultMode:(HproseResultMode)mode {
    return [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:mode simpleMode:YES];
}

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls {
    return [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode simpleMode:NO];
}

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode simpleMode:simple];
}

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls {
    return [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode simpleMode:NO];
}

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode simpleMode:simple];
}

- (oneway void) invoke:(NSString *)name callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:YES callback:callback];
}
- (oneway void) invoke:(NSString *)name resultType:(char)type callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:YES callback:callback];
}
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:YES callback:callback];
}
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:mode simpleMode:YES callback:callback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode simpleMode:NO callback:callback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode simpleMode:simple callback:callback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode simpleMode:NO callback:callback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple callback:callback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode simpleMode:simple callback:callback];
}

- (oneway void) invoke:(NSString *)name block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:YES block:block];
}
- (oneway void) invoke:(NSString *)name resultType:(char)type block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:YES block:block];
}
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:YES block:block];
}
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:'@' resultMode:mode simpleMode:YES block:block];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode simpleMode:NO block:block];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:'@' resultMode:mode simpleMode:simple block:block];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:NO block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode simpleMode:NO block:block];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:'@' resultMode:HproseResultMode_Normal simpleMode:simple block:block];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:'@' resultMode:mode simpleMode:simple block:block];
}

- (oneway void) invoke:(NSString *)name selector:(SEL)selector {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO simpleMode:YES selector:selector delegate:nil];
}
- (oneway void) invoke:(NSString *)name delegate:(id)delegate {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO simpleMode:YES selector:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO simpleMode:YES selector:selector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:NO simpleMode:NO selector:selector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:NO selector:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:NO selector:selector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:NO simpleMode:simple selector:selector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:simple selector:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args simpleMode:(BOOL)simple selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:simple selector:selector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:byRef simpleMode:NO selector:selector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef simpleMode:NO selector:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef simpleMode:NO selector:selector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:byRef simpleMode:simple selector:selector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef simpleMode:simple selector:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector delegate:(id)delegate {
    if (delegate == nil) delegate = _delegate;
    if (delegate == nil && selector == NULL) {
        [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:NULL block:nil delegate:nil selector: NULL];
        return;
    }
    if (selector == NULL) {
        selector = sel_registerName("callback");
        if (![delegate respondsToSelector:selector]) {
            selector = sel_registerName("callback:");
            if (![delegate respondsToSelector:selector]) {
                selector = sel_registerName("callback:withArgs:");
            }
        }
    }
    HproseExceptionHandler * handler = [HproseExceptionHandler new];
    [handler setClient:self];
    [handler setDelegate:delegate];
    [handler setName:name];
    Class cls = Nil;
    char type = _C_ID;
    NSMethodSignature *methodSignature = [delegate methodSignatureForSelector:selector];
    if (methodSignature == nil) {
        [handler doErrorCallback:[HproseException exceptionWithReason:
                                  [NSString stringWithFormat:
                                   @"Not support this callback: %@, the delegate doesn't respond to the selector.",
                                   NSStringFromSelector(selector)]]];
        return;
    }
    NSUInteger n = [methodSignature numberOfArguments];
    if (n < 2 || n > 4) {
        [handler doErrorCallback:[HproseException exceptionWithReason:
                                  [NSString stringWithFormat:
                                   @"Not support this callback: %@, number of arguments is wrong.",
                                   NSStringFromSelector(selector)]]];
        return;
    }
    if (n > 2) {
        const char *types = [methodSignature getArgumentTypeAtIndex:2];
        if (types != NULL && [HproseHelper isSerializableType:types[0]]) {
            if (types[0] == _C_ID) {
                if (strlen(types) > 3) {
                    NSString *className = [@(types)
                                           substringWithRange:
                                           NSMakeRange(2, strlen(types) - 3)];
                    cls = objc_getClass([className UTF8String]);
                }
            }
            type = types[0];
        }
        else {
            [handler doErrorCallback:[HproseException exceptionWithReason:
                                      [NSString stringWithFormat:@"Not support this type: %s", types]]];
            return;
        }
    }
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:type resultMode:HproseResultMode_Normal simpleMode:simple callback:NULL block:nil delegate:delegate selector: selector];
}

@end

@implementation HproseClient(PrivateMethods)

- (id) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple {
    NSData * data = [self doOutput:name withArgs:args byRef:byRef simpleMode:simple];
    data = [self sendAndReceive:data];
    id result = [self doInput:data withArgs:args resultClass:cls resultType:type resultMode:mode];
    if ([result isMemberOfClass:[HproseException class]]) {
        @throw result;
    }
    return result;
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:type resultMode:mode simpleMode:simple callback:callback block:nil delegate:_delegate selector: NULL];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:type resultMode:mode simpleMode:simple callback:NULL block:block delegate:_delegate selector: NULL];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSMutableArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback block:(HproseBlock)block delegate:(id)delegate selector:(SEL)selector {
    HproseExceptionHandler *handler = [HproseExceptionHandler new];
    [handler setClient:self];
    [handler setName:name];
    [handler setDelegate:delegate];
    @try {
        NSData *data = [self doOutput:name withArgs:args byRef:byRef simpleMode:simple];
        [self sendAsync:data receiveAsync:^(NSData *data) {
            @try {
                id result = [self doInput:data withArgs:args resultClass:cls resultType:type resultMode:mode];
                if ([result isMemberOfClass:[HproseException class]]) {
                    [handler doErrorCallback:result];
                }
                else {
                    if (callback) {
                        callback(result, args);
                    }
                    else if (block) {
                        block(result, args);
                    }
                    else if (delegate != nil && selector != NULL) {
                        NSMethodSignature *methodSignature = [delegate methodSignatureForSelector:selector];
                        NSUInteger n = [methodSignature numberOfArguments];
                        switch (n) {
                            case 2: ((void (*)(id, SEL))objc_msgSend)(delegate, selector); break;
                            case 3: {
                                switch (type) {
                                    case _C_ID: ((void (*)(id, SEL,id))objc_msgSend)(delegate, selector, result); break;
                                    case _C_CHR: ((void (*)(id, SEL,char))objc_msgSend)(delegate, selector, [result charValue]); break;
                                    case _C_UCHR: ((void (*)(id, SEL,unsigned char))objc_msgSend)(delegate, selector, [result unsignedCharValue]); break;
                                    case _C_SHT: ((void (*)(id, SEL,short))objc_msgSend)(delegate, selector, [result shortValue]); break;
                                    case _C_USHT: ((void (*)(id, SEL,unsigned short))objc_msgSend)(delegate, selector, [result unsignedShortValue]); break;
                                    case _C_INT: ((void (*)(id, SEL,int))objc_msgSend)(delegate, selector, [result intValue]); break;
                                    case _C_UINT: ((void (*)(id, SEL,unsigned int))objc_msgSend)(delegate, selector, [result unsignedIntValue]); break;
                                    case _C_LNG: ((void (*)(id, SEL,long))objc_msgSend)(delegate, selector, [result longValue]); break;
                                    case _C_ULNG: ((void (*)(id, SEL,unsigned long))objc_msgSend)(delegate, selector, [result unsignedLongValue]); break;
                                    case _C_LNG_LNG: ((void (*)(id, SEL,long long))objc_msgSend)(delegate, selector, [result longLongValue]); break;
                                    case _C_ULNG_LNG: ((void (*)(id, SEL,unsigned long long))objc_msgSend)(delegate, selector, [result unsignedLongLongValue]); break;
                                    case _C_FLT: ((void (*)(id, SEL,float))objc_msgSend)(delegate, selector, [result floatValue]); break;
                                    case _C_DBL: ((void (*)(id, SEL,double))objc_msgSend)(delegate, selector, [result doubleValue]); break;
                                    case _C_BOOL: ((void (*)(id, SEL,BOOL))objc_msgSend)(delegate, selector, [result boolValue]); break;
                                    case _C_CHARPTR: ((void (*)(id, SEL,const char *))objc_msgSend)(delegate, selector, [result UTF8String]); break;
                                }
                                break;
                            }
                            case 4: {
                                switch (type) {
                                    case _C_ID: ((void (*)(id, SEL,id,NSMutableArray *))objc_msgSend)(delegate, selector, result, args); break;
                                    case _C_CHR: ((void (*)(id, SEL,char,NSMutableArray *))objc_msgSend)(delegate, selector, [result charValue], args); break;
                                    case _C_UCHR: ((void (*)(id, SEL,unsigned char,NSMutableArray *))objc_msgSend)(delegate, selector, [result unsignedCharValue], args); break;
                                    case _C_SHT: ((void (*)(id, SEL,short,NSMutableArray *))objc_msgSend)(delegate, selector, [result shortValue], args); break;
                                    case _C_USHT: ((void (*)(id, SEL,unsigned short,NSMutableArray *))objc_msgSend)(delegate, selector, [result unsignedShortValue], args); break;
                                    case _C_INT: ((void (*)(id, SEL,int,NSMutableArray *))objc_msgSend)(delegate, selector, [result intValue], args); break;
                                    case _C_UINT: ((void (*)(id, SEL,unsigned int,NSMutableArray *))objc_msgSend)(delegate, selector, [result unsignedIntValue], args); break;
                                    case _C_LNG: ((void (*)(id, SEL,long,NSMutableArray *))objc_msgSend)(delegate, selector, [result longValue], args); break;
                                    case _C_ULNG: ((void (*)(id, SEL,unsigned long,NSMutableArray *))objc_msgSend)(delegate, selector, [result unsignedLongValue], args); break;
                                    case _C_LNG_LNG: ((void (*)(id, SEL,long long,NSMutableArray *))objc_msgSend)(delegate, selector, [result longLongValue], args); break;
                                    case _C_ULNG_LNG: ((void (*)(id, SEL,unsigned long long,NSMutableArray *))objc_msgSend)(delegate, selector, [result unsignedLongLongValue], args); break;
                                    case _C_FLT: ((void (*)(id, SEL, float,NSMutableArray *))objc_msgSend)(delegate, selector, [result floatValue], args); break;
                                    case _C_DBL: ((void (*)(id, SEL,double,NSMutableArray *))objc_msgSend)(delegate, selector, [result doubleValue], args); break;
                                    case _C_BOOL: ((void (*)(id, SEL,BOOL,NSMutableArray *))objc_msgSend)(delegate, selector, [result boolValue], args); break;
                                    case _C_CHARPTR: ((void (*)(id, SEL,const char *,NSMutableArray *))objc_msgSend)(delegate, selector, [result UTF8String], args); break;
                                }
                                break;
                            }
                        }
                    }
                }
            }
            @catch (NSException *e) {
                [handler doErrorCallback:e];
            }
        } exceptionHandler:handler];
    }
    @catch (NSException *e) {
        [handler doErrorCallback:e];
    }
}

- (HproseException *) wrongResponse:(NSData *)data {
    return [HproseException exceptionWithReason:[NSString stringWithFormat:@"Wrong Response: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
}

- (NSData *) doOutput:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple {
    NSOutputStream *ostream = [NSOutputStream outputStreamToMemory];
    [ostream open];
    @try {
        HproseWriter *writer = [HproseWriter writerWithStream:ostream simple:simple];
        [ostream writeByte:HproseTagCall];
        [writer writeString:name];
        if (args != nil && ([args count] > 0 || byRef)) {
            [writer reset];
            [writer writeArray:args];
            if (byRef) {
                [writer writeBoolean:YES];
            }
        }
        [ostream writeByte:HproseTagEnd];
        NSData *data = [ostream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        for (NSUInteger i = 0, n = filters.count; i < n; ++i) {
            data = [filters[i] outputFilter:data withContext:self];
        }
        return data;
    }
    @finally {
        [ostream close];
    }
}

- (id) doInput:(NSData *)data withArgs:(NSMutableArray *)args resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode {
    for (int i = (int)filters.count - 1; i >= 0; --i) {
        data = [filters[i] inputFilter:data withContext:self];
    }
    int tag = ((uint8_t *)[data bytes])[[data length] - 1];
    if (tag != HproseTagEnd) {
        @throw [self wrongResponse:data];
    }
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
                        result = [reader unserialize:cls withType:type];
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
                        for (NSUInteger i = 0; i < n; i++) {
                            args[i] = arguments[i];
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
