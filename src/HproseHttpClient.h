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
 * LastModified: Dec 21, 2016                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseClient.h"

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
