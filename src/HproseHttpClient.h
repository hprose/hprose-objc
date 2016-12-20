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
 * LastModified: Dec 20, 2016                             *
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
    @private NSURLSession *_session;
}

@property BOOL keepAlive;
@property int keepAliveTimeout;
@property (readonly) NSMutableDictionary<NSString *,NSString *> *header;
@property id<NSURLSessionDelegate> URLSessionDelegate;

- (void) setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;


@end
