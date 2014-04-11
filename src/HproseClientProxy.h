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
 * HproseClientProxy.h                                    *
 *                                                        *
 * hprose client proxy header for Objective-C.            *
 *                                                        *
 * LastModified: Apr 11, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>

@class HproseClient;

@interface HproseClientProxy : NSProxy;

@property (weak) Protocol *protocol;
@property (weak) HproseClient *client;
@property (copy) NSString *ns;

- init:(Protocol *)aProtocol withClient:(HproseClient *)aClient withNameSpace:(NSString *)aNameSpace;

@end
