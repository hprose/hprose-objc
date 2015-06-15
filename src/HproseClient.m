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
 * LastModified: Jun 15, 2015                             *
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

@implementation HproseClientContext

- (id) init:(HproseClient *)client {
    if (self = [super init]) {
        _client = client;
    }
    return self;
}

@end

@interface HproseClient(PrivateMethods)

- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback;
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock;
- (oneway void) errorHandler:(NSString *)name withException:(NSException *)e errorCallback:(HproseErrorCallback)errorCallback errorBlock:(HproseErrorBlock)errorBlock errorSelector:(SEL)errorSelector delegate:(id)delegate;
- (HproseException *) wrongResponse:(NSData *)data;
- (NSData *) doOutput:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple context:(HproseClientContext *)context;
- (id) doInput:(NSData *)data withArgs:(NSArray *)args resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode context:(HproseClientContext *)context;

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
    return [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:YES];
}
- (id) invoke:(NSString *)name resultType:(char)type {
    return [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:YES];
}
- (id) invoke:(NSString *)name resultClass:(Class)cls {
    return [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:YES];
}
- (id) invoke:(NSString *)name resultMode:(HproseResultMode)mode {
    return [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:YES];
}

- (id) invoke:(NSString *)name withArgs:(NSArray *)args {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls {
    return [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:NO];
}

- (id) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:simple];
}

- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls {
    return [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:NO];
}

- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple];
}
- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple {
    return [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:simple];
}

- (oneway void) invoke:(NSString *)name callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:YES callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:YES callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name resultType:(char)type callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:YES callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name resultType:(char)type callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:YES callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:YES callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:YES callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode callback:(HproseCallback)callback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:YES callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:YES callback:callback error:errorCallback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:NO callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:NO callback:callback error:errorCallback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:simple callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:simple callback:callback error:errorCallback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:NO callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:NO callback:callback error:errorCallback];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:callback error:errorCallback];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:simple callback:callback error:NULL];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:simple callback:callback error:errorCallback];
}

- (oneway void) invoke:(NSString *)name block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:YES block:block error:nil];
}
- (oneway void) invoke:(NSString *)name block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:YES block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name resultType:(char)type block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:YES block:block error:nil];
}
- (oneway void) invoke:(NSString *)name resultType:(char)type block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:YES block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:YES block:block error:nil];
}
- (oneway void) invoke:(NSString *)name resultClass:(Class)cls block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:nil byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:YES block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode block:(HproseBlock)block {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:YES block:block error:nil];
}
- (oneway void) invoke:(NSString *)name resultMode:(HproseResultMode)mode block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:nil byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:YES block:block error:errorBlock];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:NO block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:NO block:block error:errorBlock];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:NO resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:simple block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:NO resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:simple block:block error:errorBlock];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:NO block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:NO block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:NO block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:NO block:block error:errorBlock];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultType:(char)type simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:type resultMode:HproseResultMode_Normal simpleMode:simple block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple block:block error:errorBlock];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:simple block:block error:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:mode simpleMode:simple block:block error:errorBlock];
}

- (oneway void) invoke:(NSString *)name selector:(SEL)selector {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO simpleMode:YES selector:selector error:NULL delegate:nil];
}
- (oneway void) invoke:(NSString *)name selector:(SEL)selector error:(SEL)errorSelector {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO simpleMode:YES selector:selector error:errorSelector delegate:nil];
}
- (oneway void) invoke:(NSString *)name delegate:(id)delegate {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO simpleMode:YES selector:NULL error:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name error:(SEL)errorSelector delegate:(id)delegate {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO simpleMode:YES selector:NULL error:errorSelector delegate:delegate];
}
- (oneway void) invoke:(NSString *)name selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO simpleMode:YES selector:selector error:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name selector:(SEL)selector error:(SEL)errorSelector delegate:(id)delegate {
    [self invoke:name withArgs:[NSMutableArray array] byRef:NO simpleMode:YES selector:selector error:errorSelector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:NO simpleMode:NO selector:selector error:NULL delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args selector:(SEL)selector error:(SEL)errorSelector {
    [self invoke:name withArgs:args byRef:NO simpleMode:NO selector:selector error:errorSelector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:NO selector:NULL error:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args error:(SEL)errorSelector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:NO selector:NULL error:errorSelector delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:NO selector:selector error:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args selector:(SEL)selector error:(SEL)errorSelector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:NO selector:selector error:errorSelector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:NO simpleMode:simple selector:selector error:NULL delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple selector:(SEL)selector error:(SEL)errorSelector {
    [self invoke:name withArgs:args byRef:NO simpleMode:simple selector:selector error:errorSelector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:simple selector:NULL error:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple error:(SEL)errorSelector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:simple selector:NULL error:errorSelector delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:simple selector:selector error:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args simpleMode:(BOOL)simple selector:(SEL)selector error:(SEL)errorSelector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:NO simpleMode:simple selector:selector error:errorSelector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:byRef simpleMode:NO selector:selector error:NULL delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef selector:(SEL)selector error:(SEL)errorSelector {
    [self invoke:name withArgs:args byRef:byRef simpleMode:NO selector:selector error:errorSelector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef simpleMode:NO selector:NULL error:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef error:(SEL)errorSelector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef simpleMode:NO selector:NULL error:errorSelector delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef simpleMode:NO selector:selector error:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef selector:(SEL)selector error:(SEL)errorSelector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef simpleMode:NO selector:selector error:errorSelector delegate:delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector {
    [self invoke:name withArgs:args byRef:byRef simpleMode:simple selector:selector error:NULL delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector error:(SEL)errorSelector {
    [self invoke:name withArgs:args byRef:byRef simpleMode:simple selector:selector error:errorSelector delegate:nil];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef simpleMode:simple selector:NULL error:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple error:(SEL)errorSelector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef simpleMode:simple selector:NULL error:errorSelector delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector delegate:(id)delegate {
    [self invoke:name withArgs:args byRef:byRef simpleMode:simple selector:selector error:NULL delegate:delegate];
}
- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple selector:(SEL)selector error:(SEL)errorSelector delegate:(id)delegate {
    if (delegate == nil) delegate = _delegate;
    if (delegate == nil && selector == NULL) {
        [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:NULL block:nil selector: NULL errorCallback:NULL errorBlock:nil errorSelector:errorSelector delegate:nil];
        return;
    }
    if (errorSelector == NULL) {
        errorSelector = sel_registerName("errorHandler:withException:");
        if (![delegate respondsToSelector:selector]) {
            errorSelector = NULL;
        }
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
    if (![delegate respondsToSelector:selector]) {
        [self errorHandler:name withException:[HproseException exceptionWithReason:@"Can't find the callback selector."] errorCallback:NULL errorBlock:nil errorSelector:errorSelector delegate:delegate];
        return;
    }
    [self invoke:name withArgs:args byRef:byRef resultClass:Nil resultType:_C_ID resultMode:HproseResultMode_Normal simpleMode:simple callback:NULL block:nil selector: selector errorCallback:NULL errorBlock:nil errorSelector:errorSelector delegate:delegate];
}


- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback block:(HproseBlock)block selector:(SEL)selector errorCallback:(HproseErrorCallback)errorCallback errorBlock:(HproseErrorBlock)errorBlock errorSelector:(SEL)errorSelector delegate:(id)delegate {
    if (delegate != nil && selector != NULL) {
        NSMethodSignature *methodSignature = [delegate methodSignatureForSelector:selector];
        if (methodSignature == nil) {
            [self errorHandler:name
                 withException:[HproseException exceptionWithReason:
                                [NSString stringWithFormat:
                                 @"Not support this callback: %@, the delegate doesn't respond to the selector.",
                                 NSStringFromSelector(selector)]]
                 errorCallback:NULL errorBlock:nil errorSelector:errorSelector delegate:delegate];
            return;
        }
        NSUInteger n = [methodSignature numberOfArguments];
        if (n < 2 || n > 4) {
            [self errorHandler:name
                 withException:[HproseException exceptionWithReason:
                                [NSString stringWithFormat:
                                 @"Not support this callback: %@, number of arguments is wrong.",
                                 NSStringFromSelector(selector)]]
                 errorCallback:NULL errorBlock:nil errorSelector:errorSelector delegate:delegate];
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
                [self errorHandler:name
                     withException:[HproseException exceptionWithReason:
                                    [NSString stringWithFormat:@"Not support this type: %s", types]]
                     errorCallback:NULL errorBlock:nil errorSelector:errorSelector delegate:delegate];
                return;
            }
        }
    }
    HproseClientContext *context = [[HproseClientContext alloc] init:self];
    @try {
        NSData *data = [self doOutput:name withArgs:args byRef:byRef simpleMode:simple context:context];
        [self sendAsync:data receiveAsync:^(NSData *data) {
            @try {
                NSArray *_args = args;
                if (byRef && ![args isKindOfClass:[NSMutableArray class]]) {
                    _args = [args mutableCopy];
                }
                id result = [self doInput:data withArgs:_args resultClass:cls resultType:type resultMode:mode context:context];
                if ([result isMemberOfClass:[HproseException class]]) {
                    [self errorHandler:name withException:result errorCallback:errorCallback errorBlock:errorBlock errorSelector:errorSelector delegate:delegate];
                }
                else {
                    if (callback) {
                        callback(result, _args);
                    }
                    else if (block) {
                        block(result, _args);
                    }
                    else if (delegate != nil && selector != NULL) {
                        NSMethodSignature *methodSignature = [delegate methodSignatureForSelector:selector];
                        NSUInteger n = [methodSignature numberOfArguments];
                        switch (n) {
                            case 2: ((void (*)(id, SEL))objc_msgSend)(delegate, selector); break;
                            case 3: {
                                switch (type) {
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
                                switch (type) {
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
                [self errorHandler:name withException:e errorCallback:errorCallback errorBlock:errorBlock errorSelector:errorSelector delegate:delegate];
            }
        }
                  error:^(NSException *e) {
                      [self errorHandler:name withException:e errorCallback:errorCallback errorBlock:errorBlock errorSelector:errorSelector delegate:delegate];
                  }];
    }
    @catch (NSException *e) {
        [self errorHandler:name withException:e errorCallback:errorCallback errorBlock:errorBlock errorSelector:errorSelector delegate:delegate];
    }
}

@end

@implementation HproseClient(PrivateMethods)

- (id) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple {
    HproseClientContext *context = [[HproseClientContext alloc] init:self];
    NSData * data = [self doOutput:name withArgs:args byRef:byRef simpleMode:simple context:context];
    data = [self sendAndReceive:data];
    id result = [self doInput:data withArgs:args resultClass:cls resultType:type resultMode:mode context:context];
    if ([result isMemberOfClass:[HproseException class]]) {
        @throw result;
    }
    return result;
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple callback:(HproseCallback)callback error:(HproseErrorCallback)errorCallback {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:type resultMode:mode simpleMode:simple
        callback:callback block:nil selector: NULL
        errorCallback:errorCallback errorBlock:nil errorSelector:NULL delegate:_delegate];
}

- (oneway void) invoke:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode simpleMode:(BOOL)simple block:(HproseBlock)block error:(HproseErrorBlock)errorBlock {
    [self invoke:name withArgs:args byRef:byRef resultClass:cls resultType:type resultMode:mode simpleMode:simple
        callback:NULL block:block selector: NULL
        errorCallback:NULL errorBlock:errorBlock errorSelector:NULL delegate:_delegate];
}

- (oneway void) errorHandler:(NSString *)name withException:(NSException *)e errorCallback:(HproseErrorCallback)errorCallback errorBlock:(HproseErrorBlock)errorBlock errorSelector:(SEL)errorSelector delegate:(id)delegate {
    if (errorCallback) {
        errorCallback(name, e);
    }
    else if (errorBlock) {
        errorBlock(name, e);
    }
    else if (delegate != nil && errorSelector != NULL && [delegate respondsToSelector:errorSelector]) {
        ((void (*)(id, SEL, NSString *, NSException *))objc_msgSend)(delegate, errorSelector, name, e);
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

- (NSData *) doOutput:(NSString *)name withArgs:(NSArray *)args byRef:(BOOL)byRef simpleMode:(BOOL)simple context:(HproseClientContext *)context {
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
            data = [filters[i] outputFilter:data withContext:context];
        }
        return data;
    }
    @finally {
        [ostream close];
    }
}

- (id) doInput:(NSData *)data withArgs:(NSArray *)args resultClass:(Class)cls resultType:(char)type resultMode:(HproseResultMode)mode context:(HproseClientContext *)context {
    for (int i = (int)filters.count - 1; i >= 0; --i) {
        data = [filters[i] inputFilter:data withContext:context];
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
