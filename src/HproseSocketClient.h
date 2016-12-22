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
 * HproseSocketClient.h                                   *
 *                                                        *
 * hprose socket client header for Objective-C.           *
 *                                                        *
 * LastModified: Dec 22, 2016                             *
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

@interface HproseSocketClient: HproseClient {
    id _fdtrans;
    id _hdtrans;
}

@property (readonly) NSURL *url;
@property BOOL fullDuplex;
@property BOOL ipv4Preferred;
@property NSTimeInterval connectTimeout;
@property NSTimeInterval idleTimeout;
@property NSDictionary *tlsSettings;
@property NSUInteger maxPoolSize;
@end
