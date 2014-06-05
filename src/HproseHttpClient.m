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
 * LastModified: Apr 11, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import "HproseException.h"
#import "HproseHttpClient.h"

@interface AsyncInvokeContext: NSObject<NSURLConnectionDelegate> {
    @private
    NSMutableData *_buffer;
    void (^_callback)(NSData *);
    HproseExceptionHandler *_exceptionHandler;
    HproseHttpClient * _client;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection;
@end

@implementation AsyncInvokeContext

- (id) init:(HproseHttpClient *)client callback:(void (^)(NSData *))callback exceptionHandler:(HproseExceptionHandler *)exceptionHandler {
    if (self = [super init]) {
        _buffer = [NSMutableData data];
        _client = client;
        _callback = callback;
        _exceptionHandler = exceptionHandler;
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
#pragma unused(connection)
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    if ([httpResponse statusCode] != 200) {
        [_exceptionHandler doErrorCallback:[HproseException exceptionWithReason:
         [NSString stringWithFormat:@"Http error %d: %@",
          (int)[httpResponse statusCode],
          [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]]]];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
#pragma unused(connection)
    [_buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
#pragma unused(connection)
    _callback(_buffer);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_exceptionHandler doErrorCallback:[HproseException exceptionWithReason:[error localizedDescription]]];
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
        NSURLCredential *credential;
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        }
        else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
            credential = nil;
        }
        if (credential != nil) {
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


@implementation HproseHttpClient

- (id) init {
    if (self = [super init]) {
        [self setTimeout:30.0];
        [self setKeepAlive:YES];
        [self setKeepAliveTimeout:300];
        [self setURLConnectionDelegate:nil];
        _header = [NSMutableDictionary new];
    }
    return self;
}

@dynamic uri;

- (void) setUri:(NSString *)aUri {
    if ([super uri] != aUri) {
        [super setUri:aUri];
        url = [NSURL URLWithString:aUri];
    }
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

- (NSData *) sendAndReceive:(NSData *)data {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:_timeout];
    for (id field in _header) {
        [request setValue:_header[field] forHTTPHeaderField:field];
    }
    if (_keepAlive) {
        [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [request setValue:[@(_keepAliveTimeout) stringValue] forHTTPHeaderField:@"Keep-Alive"];
    }
    else {
        [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    }
    [request setHTTPShouldHandleCookies:YES];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    NSHTTPURLResponse *response;
    NSError *error;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSInteger statusCode = [response statusCode];
    if (statusCode != 200 && statusCode != 0) {
        @throw [HproseException exceptionWithReason:
                [NSString stringWithFormat:@"Http error %d: %@",
                 (int)statusCode,
                 [NSHTTPURLResponse localizedStringForStatusCode:statusCode]]];
    }
    if (data == nil) {
        @throw [HproseException exceptionWithReason:[error localizedDescription]];
    }
    return data;
}

- (oneway void) sendAsync:(NSData *)data receiveAsync:(oneway void (^)(NSData *))receiveCallback exceptionHandler:(HproseExceptionHandler *)exceptionHandler; {
    AsyncInvokeContext *context = [[AsyncInvokeContext alloc] init:self callback:receiveCallback exceptionHandler:exceptionHandler];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:_timeout];
    for (id field in _header) {
        [request setValue:_header[field] forHTTPHeaderField:field];
    }
    if (_keepAlive) {
        [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [request setValue:[@(_keepAliveTimeout) stringValue] forHTTPHeaderField:@"Keep-Alive"];
    }
    else {
        [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    }
    [request setHTTPShouldHandleCookies:YES];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [NSURLConnection connectionWithRequest:request delegate:context];
}

@end