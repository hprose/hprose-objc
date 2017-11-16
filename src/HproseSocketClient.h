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
 * LastModified: Nov 16, 2017                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#if !TARGET_OS_WATCH
#import <Foundation/Foundation.h>
#import "HproseClient.h"

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
#endif
