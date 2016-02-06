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
 * LastModified: Feb 6, 2016                              *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseClient.h"

@interface HproseHttpClient : HproseClient {
    @private NSURL *url;
}

@property NSTimeInterval timeout;
@property BOOL keepAlive;
@property int keepAliveTimeout;
@property (readonly) NSMutableDictionary *header;
@property id<NSURLConnectionDelegate> URLConnectionDelegate;
@property id<NSURLSessionDelegate> URLSessionDelegate;

- (void) setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

@end