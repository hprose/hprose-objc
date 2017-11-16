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
 * LastModified: Dec 24, 2016                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import "HproseException.h"
#import "HproseHttpClient.h"

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

@implementation HproseHttpClient

- (id) init {
    if (self = [super init]) {
        [self setKeepAlive:YES];
        [self setKeepAliveTimeout:300];
        [self setURLSessionDelegate:nil];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration: configuration
                                                 delegate: [[AsyncInvokeDelegate alloc] init:self]
                                            delegateQueue: nil];
        _header = [NSMutableDictionary<NSString *,NSString *> new];
    }
    return self;
}

- (void) close:(BOOL)cancelPendingTasks {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cancelPendingTasks) {
            [_session invalidateAndCancel];
        } else {
            [_session finishTasksAndInvalidate];
        }
    });
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

- (Promise *) sendAndReceive:(NSData *)data context:(HproseClientContext *)context {
    NSURLRequest *request = [self createRequest:data context:context];
    Promise *result = [Promise promise];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        context.userData[@"httpHeader"] = ((NSHTTPURLResponse *)response).allHeaderFields;
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (error != nil) {
            [result reject:error];
        }
        else if (statusCode != 200 && statusCode != 0) {
            NSString *status = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject: status
                                                                 forKey:NSLocalizedDescriptionKey];
            [result reject: [NSError errorWithDomain:HproseErrorDomain
                                                code:statusCode
                                            userInfo:userInfo]];
        }
        else {
            [result resolve:data];
        }
    }];
    [task resume];
    return result;
}

@end
