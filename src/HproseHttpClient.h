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
 * HproseHttpClient.h                                     *
 *                                                        *
 * hprose http client header for Objective-C.             *
 *                                                        *
 * LastModified: Dec 3, 2016                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseClient.h"

#ifdef UIKIT_EXTERN
#define HPROSE_ASYNC_QUEUE dispatch_get_main_queue()
#else
#define HPROSE_ASYNC_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#endif

@interface HproseHttpClient: HproseClient {
    @private NSURL *_url;
#if defined(__MAC_10_7) || defined(__IPHONE_7_0) || defined(__TVOS_9_0) || defined(__WATCHOS_1_0)
    @private NSURLSession *_session;
#endif
}

@property BOOL keepAlive;
@property int keepAliveTimeout;
@property (readonly) NSMutableDictionary<NSString *,NSString *> *header;
#if !defined(__MAC_10_7) && !defined(__IPHONE_7_0) && !defined(__TVOS_9_0) && !defined(__WATCHOS_1_0)
@property id<NSURLConnectionDelegate> URLConnectionDelegate;
#else
@property id<NSURLSessionDelegate> URLSessionDelegate;
#endif

- (void) setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;


@end
