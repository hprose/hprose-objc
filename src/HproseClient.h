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
 * LastModified: May 25, 2016                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/

#import <Foundation/Foundation.h>
#import "HproseInvoker.h"
#import "HproseInvokeSettings.h"
#import "HproseFilter.h"
#import "HproseContext.h"

@class HproseClient;

@protocol HproseTransporter <NSObject>

@optional

- (NSData *) sendAndReceive:(NSData *)data;

- (oneway void) sendAsync:(NSData *)data
                receiveAsync:(void (^)(NSData *))receiveCallback
                error:(void (^)(NSException *))errorCallback;
@end

@interface HproseClient : NSObject<HproseInvoker, HproseTransporter> {
    NSMutableArray *filters;
}

@property (copy) NSString *uri;
@property (getter = getFilter, setter = setFilter:)id<HproseFilter> filter;
@property id delegate;
@property (assign, nonatomic) SEL onError;
@property (assign, nonatomic) HproseErrorCallback errorCallback;
@property (copy, nonatomic) HproseErrorBlock errorHandler;

+ (id) client;
+ (id) client:(NSString *)uri;

- (id) init:(NSString *)uri;

- (void) close:(BOOL)cancelPendingTasks;
- (void) close;

- (id) useService:(Protocol *)protocol;
- (id) useService:(Protocol *)protocol withNameSpace:(NSString *)ns;

- (id<HproseFilter>) getFilter;
- (void) setFilter:(id<HproseFilter>)filter;
- (void) addFilter:(id<HproseFilter>)filter;
- (void) removeFilter:(id<HproseFilter>)filter;

@end

@interface HproseClientContext : HproseContext;

@property HproseClient* client;
@property HproseInvokeSettings *settings;

- (id) init:(HproseClient *)client settings:(HproseInvokeSettings *)settings;

@end