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
 * HproseSocketClient.m                                   *
 *                                                        *
 * hprose socket client for Objective-C.                  *
 *                                                        *
 * LastModified: Nov 16, 2017                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#if !TARGET_OS_WATCH
#import "HproseSocketClient.h"
#import "GCDAsyncSocket.h"

#define TAG_REQUEST_HEADER  1
#define TAG_REQUEST_BODY    2
#define TAG_RESPONSE_HEADER 3
#define TAG_RESPONSE_BODY   4

@interface SocketRequest : NSObject {
}

@property NSData *data;
@property HproseClientContext *context;
@property Promise *result;

- (id) init:(NSData *)data context:(HproseClientContext *)context result:(Promise *)result;

@end

@implementation SocketRequest

- (id) init:(NSData *)data context:(HproseClientContext *)context result:(Promise *)result {
    if (self = [super init]) {
        _data = data;
        _context = context;
        _result = result;
    }
    return self;
}

@end

@interface SocketConnection : NSObject<GCDAsyncSocketDelegate> {
    NSURL *_url;
    NSTimeInterval _connectTimeout;
    NSTimeInterval _idleTimeout;
    BOOL _ipv4Preferred;
    Promise *_timer;
}

@property GCDAsyncSocket *sock;

- (id) init:(HproseSocketClient *)client error:(NSError **)error;
- (void) recycle;
- (void) clean;
- (void) dealloc;

@end

@interface SocketTransporter: NSObject {
}

@property HproseSocketClient *client;
@property NSString *uri;
@property NSUInteger size;
@property (readonly) NSMutableArray<SocketConnection *> *pool;
@property (readonly) NSMutableArray<SocketRequest *> *requests;

- (id) init:(HproseSocketClient *)client;

@end

@implementation SocketConnection

- (id) init:(HproseSocketClient *)client error:(NSError **)error {
    if (self = [super init]) {
        _url = client.url;
        _connectTimeout = client.connectTimeout;
        _idleTimeout = client.idleTimeout;
        _ipv4Preferred = client.ipv4Preferred;
        _sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:[Promise dispatchQueue]];
        if ([self connect:error]) {
            return self;
        }
    }
    return self;
}

- (BOOL) connect:(NSError **)error {
    if ([_url.scheme isEqualToString:@"unix"]) {
        return [_sock connectToUrl:_url withTimeout:_connectTimeout error:error];
    }
    else if ([_url.scheme isEqualToString:@"tcp4"]) {
        [_sock setIPv4Enabled: YES];
        [_sock setIPv6Enabled: NO];
    }
    else if ([_url.scheme isEqualToString:@"tcp6"]) {
        [_sock setIPv4Enabled: NO];
        [_sock setIPv6Enabled: YES];
    }
    else {
        [_sock setIPv4PreferredOverIPv6: _ipv4Preferred];
    }
    return [_sock connectToHost:_url.host onPort:[_url.port unsignedShortValue]
                    withTimeout:_connectTimeout error:error];
    
}

- (void) recycle {
    [self clean];
    _timer = [Promise promise];
    [[_timer timeout:_idleTimeout] fail:^(NSError *error) {
        if ([error code] == PromiseRuntimeError) {
            [_sock disconnect];
        }
    }];
}

- (void) clean {
    if (_timer != nil) {
        [_timer resolve:nil];
        _timer = nil;
    }
}

- (void) dealloc {
    _sock = nil;
}

@end

@interface FullDuplexSocketConnection : SocketConnection {
    uint32_t _nextid;
}

@property NSInteger count;
@property (readonly) NSMutableArray<SocketConnection *> *pool;
@property (readonly) NSMutableArray<SocketRequest *> *requests;
@property (readonly) NSMutableDictionary<NSNumber *, Promise *> *results;
@property NSNumber *recv_id;
@property NSNumber *send_id;

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag;

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err;

@end

@implementation FullDuplexSocketConnection

- (id) init:(HproseSocketClient *)client trans:(SocketTransporter *)trans error:(NSError **)error {
    if (self = [super init:client error:error]) {
        _nextid = 0;
        _count = 0;
        _requests = trans.requests;
        _pool = trans.pool;
        _results = [NSMutableDictionary new];
        [self.sock readDataToLength:8 withTimeout:-1 tag:TAG_RESPONSE_HEADER];
    }
    return self;
}

- (void) sendNext {
    if (_count < 10) {
        SocketRequest *request = nil;
        @synchronized (_requests) {
            if (_requests.count > 0) {
                request = _requests.lastObject;
                [_requests removeLastObject];
            }
            else {
                @synchronized (_pool) {
                    if (![_pool containsObject:self]) {
                        [_pool addObject:self];
                    }
                }
            }
        }
        if (request != nil) {
            [self send:request];
        }
    }
}

- (void) send:(SocketRequest *)request {
    uint32_t nextid = ++_nextid;
    NSNumber *send_id = [NSNumber numberWithUnsignedLong:nextid];
    NSTimeInterval timeout = request.context.settings.timeout;
    if (timeout > 0) {
        [[request.result timeout:timeout] fail:^(NSError *error) {
            if ([error code] == PromiseRuntimeError) {
                [_results removeObjectForKey:send_id];
                _count--;
                [self sendNext];
                if (_count == 0) {
                    [self recycle];
                }
            }
        }];
    }
    _count++;
    _results[send_id] = request.result;
    uint8_t buf[8];
    uint32_t len = (uint32_t)request.data.length | 0x80000000;
    buf[0] = len >> 24 & 0xff;
    buf[1] = len >> 16 & 0xff;
    buf[2] = len >> 8  & 0xff;
    buf[3] = len       & 0xff;
    buf[4] = nextid >> 24 & 0xff;
    buf[5] = nextid >> 16 & 0xff;
    buf[6] = nextid >> 8  & 0xff;
    buf[7] = nextid       & 0xff;
    [self.sock writeData:[NSData dataWithBytes:buf length:8] withTimeout:-1 tag:TAG_REQUEST_HEADER];
    [self.sock writeData:request.data withTimeout:-1 tag:TAG_REQUEST_BODY];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == TAG_RESPONSE_HEADER) {
        uint8_t buf[8];
        [data getBytes:buf length:8];
        uint32_t length = ((uint32_t)(buf[0]) << 24 |
                           (uint32_t)(buf[1]) << 16 |
                           (uint32_t)(buf[2]) << 8  |
                           (uint32_t)(buf[3])) & 0x7fffffff;
        uint32_t r_id = (uint32_t)(buf[4]) << 24 |
                        (uint32_t)(buf[5]) << 16 |
                        (uint32_t)(buf[6]) << 8  |
                        (uint32_t)(buf[7]);
        _recv_id = [NSNumber numberWithUnsignedLong:r_id];
        [sock readDataToLength:length withTimeout:-1 tag:TAG_RESPONSE_BODY];
    }
    else {
        @synchronized (_results) {
            Promise *result = _results[_recv_id];
            if (result != nil) {
                [_results removeObjectForKey:_recv_id];
                _count--;
                if (_count == 0) {
                    [self recycle];
                }
                [result resolve:data];
            }
        }
        [self sendNext];
        [sock readDataToLength:8 withTimeout:-1 tag:TAG_RESPONSE_HEADER];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == TAG_REQUEST_BODY) {
        [self sendNext];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    @synchronized (_results) {
        for (NSNumber * key in _results) {
            [_results[key] reject:err];
        }
        [_results removeAllObjects];
        _count = 0;
    }
}

@end

@interface HalfDuplexSocketConnection : SocketConnection {
}

@property (readonly) NSMutableArray<SocketConnection *> *pool;
@property (readonly) NSMutableArray<SocketRequest *> *requests;
@property Promise *result;

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag;

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err;

@end

@implementation HalfDuplexSocketConnection

- (id) init:(HproseSocketClient *)client trans:(SocketTransporter *)trans error:(NSError **)error {
    if (self = [super init:client error:error]) {
        _requests = trans.requests;
        _pool = trans.pool;
    }
    return self;
}

- (void) sendNext {
    SocketRequest *request = nil;
    @synchronized (_requests) {
        if (_requests.count > 0) {
            request = _requests.lastObject;
            [_requests removeLastObject];
        }
        else {
            @synchronized (_pool) {
                if (![_pool containsObject:self]) {
                    [_pool addObject:self];
                }
            }
        }
    }
    if (request != nil) {
        [self send:request];
    }
}

- (void) send:(SocketRequest *)request {
    NSTimeInterval timeout = request.context.settings.timeout;
    if (timeout > 0) {
        [[request.result timeout:timeout] fail:^(NSError *error) {
            if ([error code] == PromiseRuntimeError) {
                [self.sock disconnect];
                @synchronized (_pool) {
                    if (![_pool containsObject:self]) {
                        [_pool addObject:self];
                    }
                }
            }
        }];
    }
    _result = request.result;
    uint8_t buf[4];
    uint32_t len = (uint32_t)request.data.length;
    buf[0] = len >> 24 & 0xff;
    buf[1] = len >> 16 & 0xff;
    buf[2] = len >> 8  & 0xff;
    buf[3] = len       & 0xff;
    [self.sock writeData:[NSData dataWithBytes:buf length:4] withTimeout:-1 tag:TAG_REQUEST_HEADER];
    [self.sock writeData:request.data withTimeout:-1 tag:TAG_REQUEST_BODY];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == TAG_RESPONSE_HEADER) {
        uint8_t buf[8];
        [data getBytes:buf length:8];
        uint32_t length = (uint32_t)(buf[0]) << 24 |
                          (uint32_t)(buf[1]) << 16 |
                          (uint32_t)(buf[2]) << 8  |
                          (uint32_t)(buf[3]);
        [sock readDataToLength:length withTimeout:-1 tag:TAG_RESPONSE_BODY];
    }
    else {
        [_result resolve:data];
        [self sendNext];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == TAG_REQUEST_BODY) {
        [sock readDataToLength:4 withTimeout:-1 tag:TAG_RESPONSE_HEADER];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    [_result reject:err];
}

@end

@implementation SocketTransporter

- (id) init:(HproseSocketClient *)client {
    if (self = [super init]) {
        _client = client;
        _uri = client.uri;
        _size = 0;
        _pool = [NSMutableArray new];
        _requests = [NSMutableArray new];
    }
    return self;
}

- (void) dealloc {
    _client = nil;
    _pool = nil;
}

- (SocketConnection *) fetch:(NSError **)error {
    if (self.pool.count > 0) {
        SocketConnection *conn = self.pool.lastObject;
        [self.pool removeLastObject];
        [conn clean];
        if ([conn.sock isDisconnected]) {
            [conn connect:error];
        }
        return conn;
    }
    return nil;
}

@end

@interface FullDuplexSocketTransporter : SocketTransporter {
}

@end

@implementation FullDuplexSocketTransporter

- (Promise *) sendAndReceive:(NSData *)data context:(HproseClientContext *)context {
    FullDuplexSocketConnection *conn;
    NSError *error = nil;
    conn = (FullDuplexSocketConnection *)[self fetch:&error];
    if (error != nil) return [Promise error:error];
    if ((conn == nil) && (self.size < self.client.maxPoolSize)) {
        conn = [[FullDuplexSocketConnection alloc] init:self.client trans:self error:&error];
        if (error != nil) return [Promise error:error];
        self.size++;
    }
    Promise *result = [Promise promise];
    SocketRequest *request = [[SocketRequest alloc] init:data context:context result:result];
    if (conn != nil) {
        [conn send:request];
    }
    else {
        [self.requests addObject:request];
    }
    return result;
}

@end

@interface HalfDuplexSocketTransporter : SocketTransporter {
}

@end

@implementation HalfDuplexSocketTransporter

- (Promise *) sendAndReceive:(NSData *)data context:(HproseClientContext *)context {
    HalfDuplexSocketConnection *conn;
    NSError *error = nil;
    conn = (HalfDuplexSocketConnection *)[self fetch:&error];
    if (error != nil) return [Promise error:error];
    if ((conn == nil) && (self.size < self.client.maxPoolSize)) {
        conn = [[HalfDuplexSocketConnection alloc] init:self.client trans:self error:&error];
        if (error != nil) return [Promise error:error];
        self.size++;
    }
    Promise *result = [Promise promise];
    SocketRequest *request = [[SocketRequest alloc] init:data context:context result:result];
    if (conn != nil) {
        [conn send:request];
    }
    else {
        [self.requests addObject:request];
    }
    return result;
}

@end

@implementation HproseSocketClient

- (id) init {
    if (self = [super init]) {
        _ipv4Preferred = YES;
        _connectTimeout = 10000;
        _idleTimeout = 30000;
        _tlsSettings = nil;
        _maxPoolSize = 10;
        _fullDuplex = NO;
        _fdtrans = nil;
        _hdtrans = nil;
    }
    return self;
}

@dynamic uri;
@dynamic uriList;

- (void) setUri:(NSString *)uri {
    [self setUriList: @[uri]];
}

- (void) setUriList:(NSArray *)uriList {
    super.uriList = uriList;
    _url = [NSURL URLWithString:super.uri];
}

- (Promise *) sendAndReceive:(NSData *)data context:(HproseClientContext *)context {
    Promise *result;
    if (_fullDuplex) {
        FullDuplexSocketTransporter *fdtrans = (FullDuplexSocketTransporter *)_fdtrans;
        if ((fdtrans == nil) || (fdtrans.uri != self.uri)) {
            fdtrans = [[FullDuplexSocketTransporter alloc] init:self];
            _fdtrans = fdtrans;
        }
        result = [fdtrans sendAndReceive:data context:context];
    }
    else {
        HalfDuplexSocketTransporter *hdtrans = (HalfDuplexSocketTransporter *)_fdtrans;
        if ((hdtrans == nil) || (hdtrans.uri != self.uri)) {
            hdtrans = [[HalfDuplexSocketTransporter alloc] init:self];
            _hdtrans = hdtrans;
        }
        result = [hdtrans sendAndReceive:data context:context];
    }
    if (context.settings.oneway) {
        [result resolve:nil];
    }
    return result;
}

@end
#endif
