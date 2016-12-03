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
 * HproseHttpClient.m                                     *
 *                                                        *
 * hprose http client for Objective-C.                    *
 *                                                        *
 * LastModified: Dec 3, 2016                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import "HproseException.h"
#import "HproseHttpClient.h"

#if !defined(__MAC_10_7) && !defined(__IPHONE_7_0) && !defined(__TVOS_9_0) && !defined(__WATCHOS_1_0)
@interface AsyncInvokeDelegate: NSObject<NSURLConnectionDelegate> {
@private
    NSMutableData *_buffer;
    BOOL _hasError;
    void (^_callback)(NSData *);
    void (^_errorHandler)(NSException *);
    HproseHttpClient * _client;
    HproseClientContext * _context;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection;
@end

@implementation AsyncInvokeDelegate

- (id) init:(HproseHttpClient *)client context:(HproseClientContext *)context callback:(void (^)(NSData *))callback errorHandler:(void (^)(NSException *)) errorHandler {
    if (self = [super init]) {
        _buffer = [NSMutableData data];
        _client = client;
        _context = context;
        _callback = callback;
        _errorHandler = errorHandler;
        _hasError = NO;
    }
    return self;
}

- (void) dealloc {
    _client = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
#pragma unused(connection)
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    _context.userData[@"httpHeader"] = response.allHTTPHeaderFields;
    if ([httpResponse statusCode] != 200) {
        _hasError = YES;
        _errorHandler([HproseException exceptionWithReason:
                       [NSString stringWithFormat:@"%d: %@",
                        (int)[httpResponse statusCode],
                        [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]]]);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
#pragma unused(connection)
    [_buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
#pragma unused(connection)
    if (!_hasError) {
        _callback(_buffer);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _hasError = YES;
    _errorHandler([HproseException exceptionWithReason:[NSString stringWithFormat:@"%d: %@",
                                                        (int)[error code],
                                                        [error localizedDescription]]]);
    if ([[_client URLConnectionDelegate] respondsToSelector:@selector(connection:didFailWithError:)]) {
        [[_client URLConnectionDelegate] connection:connection didFailWithError:error];
    }
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([[_client URLConnectionDelegate] respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)]) {
        [[_client URLConnectionDelegate] connection:connection willSendRequestForAuthenticationChallenge:challenge];
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if ([[_client URLConnectionDelegate] respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)]) {
        return [[_client URLConnectionDelegate] connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
    }
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] || [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([[_client URLConnectionDelegate] respondsToSelector:@selector(connection:didCancelAuthenticationChallenge:)]) {
        [[_client URLConnectionDelegate] connection:connection didCancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([[_client URLConnectionDelegate] respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)]) {
        [[_client URLConnectionDelegate] connection:connection didReceiveAuthenticationChallenge:challenge];
    }
    else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        }
        else {
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    if ([[_client URLConnectionDelegate] respondsToSelector:@selector(connectionShouldUseCredentialStorage:)]) {
        return [[_client URLConnectionDelegate] connectionShouldUseCredentialStorage:connection];
    }
    return NO;
}

@end
#else
@interface AsyncInvokeDelegate: NSObject<NSURLSessionDelegate> {
    @private HproseHttpClient * _client;
}
@end

@implementation AsyncInvokeDelegate

- (id) init:(HproseHttpClient *)client {
    if (self = [super init]) {
        _client = client;
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    if ([[_client URLSessionDelegate] respondsToSelector:@selector(URLSession:didBecomeInvalidWithError:)]) {
        [[_client URLSessionDelegate] URLSession:session didBecomeInvalidWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    if ([[_client URLSessionDelegate] respondsToSelector:@selector(URLSession:didReceiveChallenge:completionHandler:)]) {
        [[_client URLSessionDelegate] URLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
    }
    else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
        else {
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
    }
}

@end

#endif


@implementation HproseHttpClient

- (id) init {
    if (self = [super init]) {
        [self setKeepAlive:YES];
        [self setKeepAliveTimeout:300];
#if !defined(__MAC_10_7) && !defined(__IPHONE_7_0) && !defined(__TVOS_9_0) && !defined(__WATCHOS_1_0)
        [self setURLConnectionDelegate:nil];
#else
        [self setURLSessionDelegate:nil];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration: configuration
                                                 delegate: [[AsyncInvokeDelegate alloc] init:self]
                                            delegateQueue: nil];
#endif
        _header = [NSMutableDictionary<NSString *,NSString *> new];
    }
    return self;
}

#if defined(__MAC_10_7) || defined(__IPHONE_7_0) || defined(__TVOS_9_0) || defined(__WATCHOS_1_0)
- (void) close:(BOOL)cancelPendingTasks {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cancelPendingTasks) {
            [_session invalidateAndCancel];
        } else {
            [_session finishTasksAndInvalidate];
        }
    });
}
#endif

@dynamic uri;
@dynamic uriList;

- (void) setUri:(NSString *)uri {
    [self setUriList: @[uri]];
}

- (void) setUriList:(NSArray *)uriList {
    super.uriList = uriList;
    _url = [NSURL URLWithString:super.uri];
}

- (void) setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (field != nil) {
        if (value != nil) {
            _header[field] = value;
        }
        else {
            [_header removeObjectForKey:field];
        }
    }
}

- (NSURLRequest *) createRequest:(NSData *)data context:(HproseClientContext *)context {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
    [request setTimeoutInterval:context.settings.timeout];
    for (id field in _header) {
        [request setValue:_header[field] forHTTPHeaderField:field];
    }
    NSDictionary<NSString *,NSString *> *header = context.userData[@"httpHeader"];
    if (header != nil) {
        for (id field in _header) {
            [request setValue:header[field] forHTTPHeaderField:field];
        }
    }
    if (_keepAlive) {
        [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [request setValue:[@(_keepAliveTimeout) stringValue] forHTTPHeaderField:@"Keep-Alive"];
    }
    else {
        [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    }
    [request setValue:@"application/hprose" forHTTPHeaderField:@"Content-type"];
    [request setHTTPShouldHandleCookies:YES];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    return request;
}

- (id) sendSync:(NSData *)data context:(HproseClientContext *)context {
    NSURLRequest *request = [self createRequest:data context:context];
#if !defined(__MAC_10_7) && !defined(__IPHONE_7_0) && !defined(__TVOS_9_0) && !defined(__WATCHOS_1_0)
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *ret;
    ret = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
#else
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data, NSURLResponse *resp, NSError *err) {
        dict[@"response"] = resp;
        dict[@"error"] = err;
        dict[@"ret"] = data;
        dispatch_semaphore_signal(sem);
    }];
    [task resume];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)(dict[@"response"]);
    NSError *error = (NSError *)(dict[@"@error"]);
    NSData *ret = (NSData *)(dict[@"ret"]);
    dict = nil;
#endif
    
    NSInteger statusCode = response.statusCode;
    context.userData[@"httpHeader"] = response.allHeaderFields;
    if (statusCode != 200 && statusCode != 0) {
        return [HproseException exceptionWithReason:
                [NSString stringWithFormat:@"%d: %@",
                 (int)statusCode,
                 [NSHTTPURLResponse localizedStringForStatusCode:statusCode]]];
    }
    if (ret == nil) {
        return [HproseException exceptionWithReason:[NSString stringWithFormat:@"%d: %@",
                                                     (int)[error code],
                                                     [error localizedDescription]]];
    }
    return ret;
}

- (oneway void) sendAsync:(NSData *)data context:(HproseClientContext *)context
             receiveAsync:(void (^)(NSData *))receiveCallback
                    error:(void (^)(NSException *))errorCallback {
    NSURLRequest *request = [self createRequest:data context:context];
#if !defined(__MAC_10_7) && !defined(__IPHONE_7_0) && !defined(__TVOS_9_0) && !defined(__WATCHOS_1_0)
    AsyncInvokeDelegate *delegate = [[AsyncInvokeDelegate alloc] init:self context:context callback:receiveCallback errorHandler:errorCallback];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [connection start];
#else
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        context.userData[@"httpHeader"] = ((NSHTTPURLResponse *)response).allHeaderFields;
        dispatch_async(HPROSE_ASYNC_QUEUE, ^{
            if (data == nil) {
                NSException *e = [HproseException exceptionWithReason:[NSString stringWithFormat:@"%d: %@",
                                                                       (int)[error code],
                                                                       [error localizedDescription]]];
                errorCallback(e);
            }
            else {
                receiveCallback(data);
            }
        });
    }];
    [task resume];
#endif
}

@end
