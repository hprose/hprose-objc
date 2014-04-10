/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.net/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/
/**********************************************************\
 *                                                        *
 * HproseHttpClient.m                                     *
 *                                                        *
 * hprose http client for Objective-C.                    *
 *                                                        *
 * LastModified: Apr 10, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import "HproseException.h"
#import "HproseHttpClient.h"

@interface AsyncInvokeContext: NSObject {
    NSMutableData *_buffer;
    void (^_callback)(NSData *);
    HproseExceptionHandler *_exceptionHandler;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection;
@end

@implementation AsyncInvokeContext

- (id) init:(void (^)(NSData *))callback exceptionHandler:(HproseExceptionHandler *)exceptionHandler {
    if (self = [super init]) {
        _buffer = [NSMutableData data];
        _callback = callback;
        _exceptionHandler = exceptionHandler;
    }
    return self;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    if ([httpResponse statusCode] != 200) {
        [_exceptionHandler doErrorCallback:[HproseException exceptionWithReason:
         [NSString stringWithFormat:@"Http error %d: %@",
          (int)[httpResponse statusCode],
          [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]]]];
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data {
#pragma unused(theConnection)
    [_buffer appendData:data];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
#pragma unused(theConnection)
    [_exceptionHandler doErrorCallback:[HproseException exceptionWithReason:[error localizedDescription]]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
#pragma unused(theConnection)
    _callback(_buffer);
}

@end

@implementation HproseHttpClient

- (NSData *) sendAndReceive:(NSData *)data {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:_timeout];
    for (id field in _header) {
        [request setValue:[_header objectForKey:field] forHTTPHeaderField:field];
    }
    if (_keepAlive) {
        [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [request setValue:[[NSNumber numberWithInt:_keepAliveTimeout] stringValue] forHTTPHeaderField:@"Keep-Alive"];
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
    AsyncInvokeContext *context = [[AsyncInvokeContext alloc] init:receiveCallback exceptionHandler:exceptionHandler];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:_timeout];
    for (id field in _header) {
        [request setValue:[_header objectForKey:field] forHTTPHeaderField:field];
    }
    if (_keepAlive) {
        [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [request setValue:[[NSNumber numberWithInt:_keepAliveTimeout] stringValue] forHTTPHeaderField:@"Keep-Alive"];
    }
    else {
        [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    }
    [request setHTTPShouldHandleCookies:YES];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [NSURLConnection connectionWithRequest:request delegate:context];
}

@dynamic uri;

- (void) setUri:(NSString *)aUri {
    if ([super uri] != aUri) {
        [super setUri:aUri];
        url = [NSURL URLWithString:aUri];
    }
}

- (id) init {
    if (self = [super init]) {
        _timeout = 30.0;
        _keepAlive = YES;
        _keepAliveTimeout = 300;
        _header = [NSMutableDictionary new];
    }
    return self;
}

- (void) setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (field != nil) {
         if (value != nil) {
            [_header setObject:value forKey:field];
         }
        else {
            [_header removeObjectForKey:field];
        }
    }
}

@end