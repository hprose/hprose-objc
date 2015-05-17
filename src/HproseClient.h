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
 * HproseClient.h                                         *
 *                                                        *
 * hprose client header for Objective-C.                  *
 *                                                        *
 * LastModified: May 17, 2015                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseInvoker.h"
#import "HproseFilter.h"
#import "HproseContext.h"

typedef void (^HproseErrorEvent)(NSString *, NSException *);

@class HproseClient;

@interface HproseExceptionHandler: NSObject;

@property HproseClient* client;
@property (copy) NSString *name;
@property id delegate;

- (oneway void) doErrorCallback:(NSException *)e;

@end

@protocol HproseTransporter <NSObject>

@optional

- (NSData *) sendAndReceive:(NSData *)data;

- (oneway void) sendAsync:(NSData *)data receiveAsync:(oneway void (^)(NSData *))receiveCallback exceptionHandler:(HproseExceptionHandler *)exceptionHandler;

@end

@interface HproseClient : NSObject<HproseInvoker, HproseTransporter> {
    NSMutableArray *filters;
}

@property (copy) NSString *uri;
@property (getter = getFilter, setter = setFilter:)id<HproseFilter> filter;
@property id delegate;
@property (assign, nonatomic) SEL onError;
@property (copy, nonatomic) HproseErrorEvent errorHandler;

+ (id) client;
+ (id) client:(NSString *)uri;

- (id) init:(NSString *)uri;

- (id) useService:(Protocol *)protocol;
- (id) useService:(Protocol *)protocol withNameSpace:(NSString *)ns;

- (id<HproseFilter>) getFilter;
- (void) setFilter:(id<HproseFilter>)filter;
- (void) addFilter:(id<HproseFilter>)filter;
- (void) removeFilter:(id<HproseFilter>)filter;

@end

@interface HproseClientContext : HproseContext;

@property HproseClient* client;

- (id) init:(HproseClient *)client;

@end