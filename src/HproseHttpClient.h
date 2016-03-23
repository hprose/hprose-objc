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
 * LastModified: Mar 23, 2016                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseClient.h"

@interface HproseHttpClient : HproseClient {
    @private NSURL *_url;
#if defined(__MAC_10_7) || defined(__IPHONE_7_0) || defined(__TVOS_9_0) || defined(__WATCHOS_1_0)
    @private NSURLSession *_session;
#endif
}

@property NSTimeInterval timeout;
@property BOOL keepAlive;
@property int keepAliveTimeout;
@property (readonly) NSMutableDictionary *header;
#if !defined(__MAC_10_7) && !defined(__IPHONE_7_0) && !defined(__TVOS_9_0) && !defined(__WATCHOS_1_0)
@property id<NSURLConnectionDelegate> URLConnectionDelegate;
#else
@property id<NSURLSessionDelegate> URLSessionDelegate;
#endif

- (void) setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;


@end